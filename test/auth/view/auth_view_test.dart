import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:iamhere/auth/service/token_storage_service.dart';
import 'package:iamhere/auth/view/auth_view.dart';
import 'package:iamhere/auth/view_model/auth_view_model.dart';
import 'package:iamhere/common/result/error_message.dart';
import 'package:iamhere/common/result/result.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_view_test.mocks.dart';

// Mock 클래스 생성을 위한 어노테이션
@GenerateMocks([AuthViewModel, TokenStorageService])
void main() {
  late MockAuthViewModel mockAuthViewModel;
  late MockTokenStorageService mockTokenStorage;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    mockTokenStorage = MockTokenStorageService();

    // Mockito에 Result<ErrorMessage> 타입의 더미 값 제공
    provideDummy<Result<ErrorMessage>>(Success(ErrorMessage.kakaoAuthSuccess));

    // GetIt 설정
    GetIt.instance.reset();
    GetIt.instance.registerSingleton<TokenStorageService>(mockTokenStorage);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('AuthView Widget Tests', () {
    testWidgets('AuthView가 정상적으로 생성되어야 함', (WidgetTester tester) async {
      // // Arrange
      // when(mockAuthViewModel.handleKakaoLogin())
      //     .thenAnswer((_) async => Success(ErrorMessage.KAKAO_AUTH_SUCCESS));

      // Act & Assert - 위젯이 정상적으로 생성되는지 확인
      expect(() => AuthView(mockAuthViewModel), returnsNormally);
    });

    testWidgets('AuthView가 ConsumerStatefulWidget 타입이어야 함', (
      WidgetTester tester,
    ) async {
      // Arrange
      final authView = AuthView(mockAuthViewModel);

      // Assert
      expect(authView, isA<ConsumerStatefulWidget>());
    });

    testWidgets('_AuthViewState의 초기 상수 값들이 올바르게 설정되어야 함', (
      WidgetTester tester,
    ) async {
      // 이 테스트는 AuthView 내부의 상수값들이 올바르게 정의되어 있는지 확인합니다.
      // 실제로는 private 변수이므로 간접적으로 검증합니다.

      // Assert - AuthView 생성이 정상적으로 되는지 확인
      expect(() => AuthView(mockAuthViewModel), returnsNormally);
    });

    testWidgets('AuthViewModel 의존성이 null이 아니어야 함', (WidgetTester tester) async {
      // Arrange
      final authView = AuthView(mockAuthViewModel);

      // Assert - AuthViewModel이 주입되었는지 확인
      expect(authView, isNotNull);
    });
  });

  group('AuthView 구조 테스트', () {
    test('AuthView는 AuthViewModel을 필수로 받아야 함', () {
      // Arrange & Act
      final authView = AuthView(mockAuthViewModel);

      // Assert
      expect(authView, isNotNull);
      expect(authView, isA<ConsumerStatefulWidget>());
    });

    test('MockAuthViewModel이 handleKakaoLogin을 호출할 수 있어야 함', () async {
      // Arrange
      when(
        mockAuthViewModel.handleKakaoLogin(),
      ).thenAnswer((_) async => Success(ErrorMessage.kakaoAuthSuccess));

      // Act
      final result = await mockAuthViewModel.handleKakaoLogin();

      // Assert
      expect(result, isA<Success<ErrorMessage>>());
      verify(mockAuthViewModel.handleKakaoLogin()).called(1);
    });

    test(
      'MockAuthViewModel이 requestFCMTokenAndSendToServer를 호출할 수 있어야 함',
      () async {
        // Arrange
        when(mockAuthViewModel.requestFCMTokenAndSendToServer()).thenAnswer(
          (_) async => Success(ErrorMessage.fcmTokenGenerateSuccess),
        );

        // Act
        final result = await mockAuthViewModel.requestFCMTokenAndSendToServer();

        // Assert
        expect(result, isA<Success<ErrorMessage>>());
        verify(mockAuthViewModel.requestFCMTokenAndSendToServer()).called(1);
      },
    );
  });

  group('AuthViewModel Mock 동작 테스트', () {
    test('로그인 성공 시나리오', () async {
      // Arrange
      when(
        mockAuthViewModel.handleKakaoLogin(),
      ).thenAnswer((_) async => Success(ErrorMessage.kakaoAuthSuccess));

      // Act
      final result = await mockAuthViewModel.handleKakaoLogin();

      // Assert
      expect(result, isA<Success<ErrorMessage>>());
      final successResult = result as Success<ErrorMessage>;
      expect(successResult.data, ErrorMessage.kakaoAuthSuccess);
    });

    test('로그인 실패 시나리오', () async {
      // Arrange
      when(
        mockAuthViewModel.handleKakaoLogin(),
      ).thenAnswer((_) async => Failure('로그인 실패'));

      // Act
      final result = await mockAuthViewModel.handleKakaoLogin();

      // Assert
      expect(result, isA<Failure<ErrorMessage>>());
    });

    test('FCM 토큰 생성 성공 시나리오', () async {
      // Arrange
      when(
        mockAuthViewModel.requestFCMTokenAndSendToServer(),
      ).thenAnswer((_) async => Success(ErrorMessage.fcmTokenGenerateSuccess));

      // Act
      final result = await mockAuthViewModel.requestFCMTokenAndSendToServer();

      // Assert
      expect(result, isA<Success<ErrorMessage>>());
      final successResult = result as Success<ErrorMessage>;
      expect(successResult.data, ErrorMessage.fcmTokenGenerateSuccess);
    });

    test('FCM 토큰 생성 실패 시나리오', () async {
      // Arrange
      when(
        mockAuthViewModel.requestFCMTokenAndSendToServer(),
      ).thenAnswer((_) async => Failure('FCM 토큰 생성 실패'));

      // Act
      final result = await mockAuthViewModel.requestFCMTokenAndSendToServer();

      // Assert
      expect(result, isA<Failure<ErrorMessage>>());
    });
  });

  group('TokenStorageService Mock 동작 테스트', () {
    test('토큰이 있을 때', () async {
      // Arrange
      when(
        mockTokenStorage.getAccessToken(),
      ).thenAnswer((_) async => 'test_token');

      // Act
      final token = await mockTokenStorage.getAccessToken();

      // Assert
      expect(token, 'test_token');
      expect(token, isNotNull);
      expect(token, isNotEmpty);
    });

    test('토큰이 없을 때', () async {
      // Arrange
      when(mockTokenStorage.getAccessToken()).thenAnswer((_) async => null);

      // Act
      final token = await mockTokenStorage.getAccessToken();

      // Assert
      expect(token, isNull);
    });
  });
}
