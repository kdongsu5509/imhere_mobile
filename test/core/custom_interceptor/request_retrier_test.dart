import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iamhere/core/custom_interceptor/request_retrier.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'request_retrier_test.mocks.dart';

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

@GenerateMocks([Dio])
void main() {
  late RequestRetrier requestRetrier;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    requestRetrier = RequestRetrier(dio: mockDio);
  });

  group('RequestRetrier', () {
    test('can add request to queue', () {
      // 요청을 큐에 추가 가능
      final options = RequestOptions(path: '/api/test');
      final handler = MockErrorInterceptorHandler();

      requestRetrier.addToQueue(options, handler);

      // 큐에 추가되었는지는 내부 상태이므로 직접 검증 불가
      // retryAll이나 failAll 호출 시 동작으로 간접 검증
    });

    test('retries request with new token on retryAll', () async {
      // retryAll 시 새 토큰으로 요청 재시도
      const newToken = 'new_access_token';
      final options = RequestOptions(path: '/api/test');
      final handler = MockErrorInterceptorHandler();
      final response = Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true},
      );

      when(mockDio.fetch(options)).thenAnswer((_) async => response);

      requestRetrier.addToQueue(options, handler);
      requestRetrier.retryAll(newToken);

      await Future.delayed(Duration(milliseconds: 100));

      verify(mockDio.fetch(options)).called(1);
      expect(options.headers['Authorization'], 'Bearer $newToken');
    });

    test('clears queue after retryAll', () async {
      // retryAll 후 큐 비워짐
      const newToken = 'token';
      final options = RequestOptions(path: '/api/test');
      final handler = MockErrorInterceptorHandler();
      final response = Response(requestOptions: options, statusCode: 200);

      when(mockDio.fetch(options)).thenAnswer((_) async => response);

      requestRetrier.addToQueue(options, handler);
      requestRetrier.retryAll(newToken);
      await Future.delayed(Duration(milliseconds: 100));

      reset(mockDio);
      requestRetrier.retryAll(newToken);
      await Future.delayed(Duration(milliseconds: 100));

      verifyNever(mockDio.fetch(options));
    });

    test('fails all requests on failAll', () {
      // failAll 시 모든 요청 실패 처리
      final options1 = RequestOptions(path: '/api/test1');
      final options2 = RequestOptions(path: '/api/test2');
      final handler1 = MockErrorInterceptorHandler();
      final handler2 = MockErrorInterceptorHandler();
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/auth/reissue'),
      );

      requestRetrier.addToQueue(options1, handler1);
      requestRetrier.addToQueue(options2, handler2);
      requestRetrier.failAll(error);

      verify(handler1.reject(error)).called(1);
      verify(handler2.reject(error)).called(1);
    });

    test('clears queue after failAll', () {
      // failAll 후 큐 비워짐
      final options = RequestOptions(path: '/api/test');
      final handler = MockErrorInterceptorHandler();
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/auth/reissue'),
      );

      requestRetrier.addToQueue(options, handler);
      requestRetrier.failAll(error);

      reset(handler);
      final newError = DioException(
        requestOptions: RequestOptions(path: '/api/test2'),
      );
      requestRetrier.failAll(newError);

      verifyNever(handler.reject(newError));
    });
  });
}
