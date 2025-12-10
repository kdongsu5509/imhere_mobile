import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iamhere/auth/service/token_storage_service.dart';
import 'package:iamhere/core/custom_interceptor/auth_interceptor.dart';
import 'package:iamhere/core/custom_interceptor/request_retrier.dart';
import 'package:iamhere/core/custom_interceptor/token_refresher.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_interceptor_test.mocks.dart';

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

@GenerateMocks([
  TokenStorageService,
  TokenRefresher,
  RequestRetrier,
])
void main() {
  late AuthInterceptor authInterceptor;
  late MockTokenStorageService mockTokenStorage;
  late MockTokenRefresher mockRefresher;
  late MockRequestRetrier mockRetrier;

  setUp(() {
    mockTokenStorage = MockTokenStorageService();
    mockRefresher = MockTokenRefresher();
    mockRetrier = MockRequestRetrier();
    authInterceptor = AuthInterceptor(
      mockTokenStorage,
      mockRefresher,
      mockRetrier,
    );
  });

  group('AuthInterceptor - onRequest', () {
    test('does not add token for public endpoints', () async {
      // Public endpoint는 토큰 추가 안함
      final options = RequestOptions(path: '/api/v1/auth/login');
      final handler = MockRequestInterceptorHandler();

      authInterceptor.onRequest(options, handler);
      await Future.delayed(Duration(milliseconds: 10));

      verify(handler.next(options)).called(1);
      verifyNever(mockTokenStorage.getAccessToken());
    });

    test('adds token for private endpoints', () async {
      // Private endpoint는 토큰 추가
      const token = 'access_token';
      final options = RequestOptions(path: '/api/v1/user/profile');
      final handler = MockRequestInterceptorHandler();

      when(mockTokenStorage.getAccessToken()).thenAnswer((_) async => token);

      authInterceptor.onRequest(options, handler);
      await Future.delayed(Duration(milliseconds: 10));

      verify(mockTokenStorage.getAccessToken()).called(1);
      expect(options.headers['Authorization'], 'Bearer $token');
      verify(handler.next(options)).called(1);
    });
  });
}

