import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iamhere/auth/service/auth_service.dart';
import 'package:iamhere/auth/service/token_storage_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_service_test.mocks.dart';

// Mock 클래스 생성을 위한 어노테이션
@GenerateMocks([Dio, TokenStorageService])
void main() {
  late AuthService authService;
  late MockDio mockDio;
  late MockTokenStorageService mockTokenStorage;

  setUp(() {
    mockDio = MockDio();
    mockTokenStorage = MockTokenStorageService();
    authService = AuthService(mockDio, mockTokenStorage);
  });

  group('AuthService - sendIdTokenToServer', () {
    const testIdToken = 'test_id_token_123';
    const testAccessToken = 'test_access_token_456';
    const testRefreshToken = 'test_refresh_token_789';

    test('성공: 200 응답으로 토큰을 받아서 저장해야 함', () async {
      // Arrange
      final responseData = {
        'accessToken': testAccessToken,
        'refreshToken': testRefreshToken,
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          ));

      when(mockTokenStorage.saveAccessToken(any))
          .thenAnswer((_) async => Future.value());
      when(mockTokenStorage.saveRefreshToken(any))
          .thenAnswer((_) async => Future.value());

      // Act
      await authService.sendIdTokenToServer(testIdToken);

      // Assert
      verify(mockDio.post(
        '/api/v1/auth/login',
        data: argThat(
          isA<Map<String, dynamic>>()
              .having((m) => m['provider'], 'provider', 'KAKAO')
              .having((m) => m['idToken'], 'idToken', testIdToken),
          named: 'data',
        ),
      )).called(1);

      verify(mockTokenStorage.saveAccessToken(testAccessToken)).called(1);
      verify(mockTokenStorage.saveRefreshToken(testRefreshToken)).called(1);
    });

    test('성공: 201 응답으로 토큰을 받아서 저장해야 함', () async {
      // Arrange
      final responseData = {
        'accessToken': testAccessToken,
        'refreshToken': testRefreshToken,
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 201,
            requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          ));

      when(mockTokenStorage.saveAccessToken(any))
          .thenAnswer((_) async => Future.value());
      when(mockTokenStorage.saveRefreshToken(any))
          .thenAnswer((_) async => Future.value());

      // Act
      await authService.sendIdTokenToServer(testIdToken);

      // Assert
      verify(mockTokenStorage.saveAccessToken(testAccessToken)).called(1);
      verify(mockTokenStorage.saveRefreshToken(testRefreshToken)).called(1);
    });

    test('성공: accessToken만 있을 때 accessToken만 저장해야 함', () async {
      // Arrange
      final responseData = {
        'accessToken': testAccessToken,
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          ));

      when(mockTokenStorage.saveAccessToken(any))
          .thenAnswer((_) async => Future.value());

      // Act
      await authService.sendIdTokenToServer(testIdToken);

      // Assert
      verify(mockTokenStorage.saveAccessToken(testAccessToken)).called(1);
      verifyNever(mockTokenStorage.saveRefreshToken(any));
    });

    test('성공: refreshToken만 있을 때 refreshToken만 저장해야 함', () async {
      // Arrange
      final responseData = {
        'refreshToken': testRefreshToken,
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          ));

      when(mockTokenStorage.saveRefreshToken(any))
          .thenAnswer((_) async => Future.value());

      // Act
      await authService.sendIdTokenToServer(testIdToken);

      // Assert
      verify(mockTokenStorage.saveRefreshToken(testRefreshToken)).called(1);
      verifyNever(mockTokenStorage.saveAccessToken(any));
    });

    test('성공: 토큰이 null일 때 저장하지 않아야 함', () async {
      // Arrange
      final responseData = {
        'accessToken': null,
        'refreshToken': null,
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          ));

      // Act
      await authService.sendIdTokenToServer(testIdToken);

      // Assert
      verifyNever(mockTokenStorage.saveAccessToken(any));
      verifyNever(mockTokenStorage.saveRefreshToken(any));
    });

    test('실패: DioException 발생 시 Exception을 던져야 함', () async {
      // Arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        error: 'Network error',
        type: DioExceptionType.connectionTimeout,
      ));

      // Act & Assert
      expect(
        () => authService.sendIdTokenToServer(testIdToken),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('자체 백엔드 서버에 토큰 전송 실패'),
        )),
      );

      verifyNever(mockTokenStorage.saveAccessToken(any));
      verifyNever(mockTokenStorage.saveRefreshToken(any));
    });

    test('실패: 401 응답 시 토큰을 저장하지 않아야 함', () async {
      // Arrange
      final responseData = {
        'accessToken': testAccessToken,
        'refreshToken': testRefreshToken,
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 401,
            requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          ));

      // Act
      await authService.sendIdTokenToServer(testIdToken);

      // Assert
      verifyNever(mockTokenStorage.saveAccessToken(any));
      verifyNever(mockTokenStorage.saveRefreshToken(any));
    });

    test('실패: 500 응답 시 토큰을 저장하지 않아야 함', () async {
      // Arrange
      final responseData = {
        'accessToken': testAccessToken,
        'refreshToken': testRefreshToken,
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 500,
            requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          ));

      // Act
      await authService.sendIdTokenToServer(testIdToken);

      // Assert
      verifyNever(mockTokenStorage.saveAccessToken(any));
      verifyNever(mockTokenStorage.saveRefreshToken(any));
    });

    test('실패: 네트워크 타임아웃 시 Exception을 던져야 함', () async {
      // Arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        type: DioExceptionType.receiveTimeout,
      ));

      // Act & Assert
      expect(
        () => authService.sendIdTokenToServer(testIdToken),
        throwsA(isA<Exception>()),
      );
    });

    test('실패: 서버 에러 응답 시 Exception을 던져야 함', () async {
      // Arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        ),
        type: DioExceptionType.badResponse,
      ));

      // Act & Assert
      expect(
        () => authService.sendIdTokenToServer(testIdToken),
        throwsA(isA<Exception>()),
      );
    });
  });
}
