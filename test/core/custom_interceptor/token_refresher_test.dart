import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iamhere/auth/service/token_storage_service.dart';
import 'package:iamhere/core/custom_interceptor/token_refresher.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'token_refresher_test.mocks.dart';

@GenerateMocks([TokenStorageService, Dio])
void main() {
  late MockTokenStorageService mockTokenStorage;
  late MockDio mockRefreshDio;

  setUp(() {
    mockTokenStorage = MockTokenStorageService();
    mockRefreshDio = MockDio();
  });

  group('TokenRefresher', () {
    test('returns null when no refresh token exists', () async {
      // 리프레시 토큰이 없으면 null 반환
      when(mockTokenStorage.getRefreshToken()).thenAnswer((_) async => null);

      final refresher = TokenRefresher(
        mockTokenStorage,
        refreshDioFactory: () => mockRefreshDio,
      );

      final result = await refresher.refresh();

      expect(result, null);
      verify(mockTokenStorage.getRefreshToken()).called(1);
    });

    test('returns new access token on successful refresh', () async {
      // 토큰 갱신 성공 시 새 액세스 토큰 반환
      const refreshToken = 'refresh_token';
      const newAccessToken = 'new_access_token';

      when(mockTokenStorage.getRefreshToken())
          .thenAnswer((_) async => refreshToken);
      when(mockRefreshDio.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/api/v1/auth/reissue'),
                statusCode: 200,
                data: {'accessToken': newAccessToken},
              ));
      when(mockTokenStorage.saveAccessToken(any))
          .thenAnswer((_) async => {});

      final refresher = TokenRefresher(
        mockTokenStorage,
        refreshDioFactory: () => mockRefreshDio,
      );

      final result = await refresher.refresh();

      expect(result, newAccessToken);
    });

    test('returns null on API error', () async {
      // API 오류 발생 시 null 반환
      when(mockTokenStorage.getRefreshToken())
          .thenAnswer((_) async => 'token');
      when(mockRefreshDio.post(any, data: anyNamed('data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/reissue'),
      ));

      final refresher = TokenRefresher(
        mockTokenStorage,
        refreshDioFactory: () => mockRefreshDio,
      );

      final result = await refresher.refresh();

      expect(result, null);
    });

    test('returns null when status code is not 200', () async {
      // 상태 코드가 200이 아니면 null 반환
      when(mockTokenStorage.getRefreshToken())
          .thenAnswer((_) async => 'token');
      when(mockRefreshDio.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/api/v1/auth/reissue'),
                statusCode: 401,
                data: {},
              ));

      final refresher = TokenRefresher(
        mockTokenStorage,
        refreshDioFactory: () => mockRefreshDio,
      );

      final result = await refresher.refresh();

      expect(result, null);
    });

    test('saves both tokens when both are returned', () async {
      // 두 토큰 모두 반환되면 모두 저장
      const refreshToken = 'refresh';
      const newAccess = 'new_access';
      const newRefresh = 'new_refresh';

      when(mockTokenStorage.getRefreshToken())
          .thenAnswer((_) async => refreshToken);
      when(mockRefreshDio.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/api/v1/auth/reissue'),
                statusCode: 200,
                data: {
                  'accessToken': newAccess,
                  'refreshToken': newRefresh,
                },
              ));
      when(mockTokenStorage.saveAccessToken(any))
          .thenAnswer((_) async => {});
      when(mockTokenStorage.saveRefreshToken(any))
          .thenAnswer((_) async => {});

      final refresher = TokenRefresher(
        mockTokenStorage,
        refreshDioFactory: () => mockRefreshDio,
      );

      final result = await refresher.refresh();

      expect(result, newAccess);
      verify(mockTokenStorage.saveAccessToken(newAccess)).called(1);
      verify(mockTokenStorage.saveRefreshToken(newRefresh)).called(1);
    });
  });
}
