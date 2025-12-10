import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iamhere/core/custom_interceptor/auth_interceptor.dart';
import 'package:injectable/injectable.dart';

@module
abstract class RegisterModule {
  String get serverUrl => dotenv.env['SERVER_URL'] ?? 'http://localhost:8080';

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @lazySingleton
  Dio dio(AuthInterceptor authInterceptor) {
    int connectionTimeoutSeconds = 10;
    int receiveTimeoutSeconds = 10;

    final dio = Dio(
      _dioBaseOptions(connectionTimeoutSeconds, receiveTimeoutSeconds),
    );
    dio.interceptors.add(authInterceptor);
    _addLogInterceptor(dio);

    return dio;
  }

  BaseOptions _dioBaseOptions(
    int connectionTimeoutSeconds,
    int receiveTimeoutSeconds,
  ) {
    return BaseOptions(
      baseUrl: serverUrl,
      connectTimeout: Duration(seconds: connectionTimeoutSeconds),
      receiveTimeout: Duration(seconds: receiveTimeoutSeconds),
      headers: {'Content-Type': 'application/json'},
    );
  }

  void _addLogInterceptor(Dio dio) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }
}
