import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

class _PendingRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.requestOptions, this.handler);
}

@lazySingleton
class RequestRetrier {
  final Dio? _dio;
  final List<_PendingRequest> _pendingRequests = [];

  RequestRetrier({Dio? dio}) : _dio = dio;

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
          error: 'Dio instance not available',
        ),
      );
      return;
    }

    try {
      final response = await _dio.fetch(options);
      pending.handler.resolve(response);
    } catch (e) {
      pending.handler.reject(DioException(requestOptions: options, error: e));
    }
  }
}
