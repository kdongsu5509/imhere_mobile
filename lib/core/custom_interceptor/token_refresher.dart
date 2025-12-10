import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iamhere/auth/service/token_storage_service.dart';
import 'package:injectable/injectable.dart';

const String _tokenReissueEndPoint = '/api/v1/auth/reissue';

typedef DioFactory = Dio Function();

@lazySingleton
class TokenRefresher {
  final TokenStorageService _tokenStorage;
  final String? _baseUrl;
  final DioFactory? _refreshDioFactory;

  TokenRefresher(
    this._tokenStorage, {
    String? baseUrl,
    DioFactory? refreshDioFactory,
  })  : _baseUrl = baseUrl,
        _refreshDioFactory = refreshDioFactory;

  Future<String?> refresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final refreshDio = _refreshDioFactory?.call() ?? _createRefreshDio();
      final response = await refreshDio.post(
        _tokenReissueEndPoint,
        data: {'refreshToken': refreshToken},
      );
      return await _saveTokens(response);
    } catch (_) {
      return null;
    }
  }

  Dio _createRefreshDio() {
    final baseUrl = _baseUrl ?? dotenv.env['SERVER_URL'] ?? 'http://localhost:8080';
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<String?> _saveTokens(Response response) async {
    if (response.statusCode != 200) return null;

    final newAccess = response.data['accessToken'];
    final newRefresh = response.data['refreshToken'];

    if (newAccess != null) await _tokenStorage.saveAccessToken(newAccess);
    if (newRefresh != null) await _tokenStorage.saveRefreshToken(newRefresh);

    return newAccess;
  }
}
