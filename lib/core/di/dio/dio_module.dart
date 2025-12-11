import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iamhere/auth/service/token_storage_service.dart';
import 'package:iamhere/common/result/error_analyst.dart';
import 'package:injectable/injectable.dart';

const List<String> _publicEndpoints = [
  '/api/v1/auth/login',
  '/api/v1/auth/reissue',
];

const String _tokenReissueEndPoint = '/api/v1/auth/reissue';

@module
abstract class DioModule {
  String get serverUrl => dotenv.env['SERVER_URL'] ?? 'http://localhost:8080';

  Dio dio(TokenStorageService tokenStorage) {
    int connectionTimeoutSeconds = 10;
    int receiveTimeoutSeconds = 10;

    // Create helper instances
    final refresher = _TokenRefresher(tokenStorage, serverUrl);
    final retrier = _RequestRetrier();

    final dio = Dio(
      _dioBaseOptions(connectionTimeoutSeconds, receiveTimeoutSeconds),
    );

    // Add interceptors
    final authInterceptor = _AuthInterceptor(tokenStorage, refresher, retrier);
    dio.interceptors.add(authInterceptor);
    _addLogInterceptor(dio);

    // Inject dio into retrier (breaking circular dependency)
    retrier._setDio(dio);

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

// ========== Private Helper Classes ==========

class _PendingRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.requestOptions, this.handler);
}

class _RequestRetrier {
  Dio? _dio;
  final List<_PendingRequest> _pendingRequests = [];

  void _setDio(Dio dio) {
    _dio = dio;
  }

  void addToQueue(RequestOptions options, ErrorInterceptorHandler handler) {
    _pendingRequests.add(_PendingRequest(options, handler));
  }

  void retryAll(String newAccessToken) {
    for (final pending in _pendingRequests) {
      _retryRequest(pending, newAccessToken);
    }
    _pendingRequests.clear();
  }

  void failAll(DioException err) {
    for (final pending in _pendingRequests) {
      pending.handler.reject(err);
    }
    _pendingRequests.clear();
  }

  void _retryRequest(_PendingRequest pending, String token) async {
    final options = pending.requestOptions;
    options.headers['Authorization'] = 'Bearer $token';

    if (_dio == null) {
      pending.handler.reject(
        DioException(
          requestOptions: options,
          error: 'Dio instance not set',
        ),
      );
      return;
    }

    try {
      final response = await _dio!.fetch(options);
      pending.handler.resolve(response);
    } catch (e) {
      pending.handler.reject(DioException(requestOptions: options, error: e));
    }
  }
}

class _TokenRefresher {
  final TokenStorageService _tokenStorage;
  final String _baseUrl;

  _TokenRefresher(this._tokenStorage, this._baseUrl);

  Future<String?> refresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final refreshDio = _createRefreshDio();
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
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
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

class _AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage;
  final _TokenRefresher _refresher;
  final _RequestRetrier _retrier;

  bool _isRefreshing = false;

  _AuthInterceptor(this._tokenStorage, this._refresher, this._retrier);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_publicEndpoints.any((path) => options.path.contains(path))) {
      return handler.next(options);
    }
    final token = await _tokenStorage.getAccessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ErrorAnalyst.log(err.toString(), err.stackTrace);

    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (err.requestOptions.path.contains('/reissue')) {
      _forceLogout(err, handler);
      return;
    }

    _handleUnauthorized(err, handler);
  }

  void _handleUnauthorized(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isRefreshing) {
      _retrier.addToQueue(err.requestOptions, handler);
      return;
    }
    _isRefreshing = true;

    final newToken = await _refresher.refresh();

    if (newToken != null) {
      _onRefreshSuccess(newToken, err, handler);
    } else {
      _forceLogout(err, handler);
    }

    _isRefreshing = false;
  }

  void _onRefreshSuccess(
    String newToken,
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    _retrier.addToQueue(err.requestOptions, handler);
    _retrier.retryAll(newToken);
  }

  void _forceLogout(DioException err, ErrorInterceptorHandler handler) {
    _tokenStorage.deleteAllTokens();
    _retrier.failAll(err);
    handler.reject(err);
  }
}
