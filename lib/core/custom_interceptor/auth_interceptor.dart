import 'package:dio/dio.dart';
import 'package:iamhere/auth/service/token_storage_service.dart';
import 'package:iamhere/common/result/error_analyst.dart';
import 'package:injectable/injectable.dart'; // ErrorAnalyst가 injectable이라고 가정

import 'request_retrier.dart';
import 'token_refresher.dart';

const List<String> _publicEndpoints = [
  '/api/v1/auth/login',
  '/api/v1/auth/reissue',
];

@lazySingleton
class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage;
  final TokenRefresher _refresher;
  final RequestRetrier _retrier;

  bool _isRefreshing = false;

  AuthInterceptor(this._tokenStorage, this._refresher, this._retrier);

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
    // ErrorAnalyst 활용
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
