import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:iamhere/auth/service/token_storage_service.dart';
import 'package:iamhere/auth/view/auth_view.dart';
import 'package:iamhere/auth/view/component/login_button.dart';
import 'package:iamhere/auth/view_model/auth_view_model.dart';
import 'package:iamhere/common/result/result.dart';
import 'package:iamhere/common/result/result_message.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_view_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AuthViewModel>(), MockSpec<TokenStorageService>()])
void main() {
  late MockAuthViewModel mockAuthViewModel;
  late MockTokenStorageService mockTokenStorageService;

  provideDummy<Result<ResultMessage>>(
      Success(ResultMessage.kakaoAuthSuccess)
  );

  setUp(() async {
    mockAuthViewModel = MockAuthViewModel();
    mockTokenStorageService = MockTokenStorageService();

    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<TokenStorageService>(mockTokenStorageService);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(402, 874),
        builder: (context, child) {
          return MaterialApp(
            home: AuthView(mockAuthViewModel),
          );
        },
      ),
    );
  }

  group('AuthView Widget Tests', () {
    testWidgets('화면 요소들이 정상적으로 렌더링 되어야 한다', (WidgetTester tester) async {
      // given & when
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(createWidgetUnderTest());

      // then
      expect(find.text('Imhere'), findsOneWidget); // 타이틀 확인
      expect(find.text('정해진 장소를 지나면 문자를 보낼게요!'), findsOneWidget); // 서브타이틀 확인
      expect(find.byType(LoginButton), findsOneWidget); // 로그인 버튼 확인
      expect(find.text('위치'), findsOneWidget); // 권한 텍스트 확인
    });

    testWidgets('로그인 버튼을 누르면 로그인 로직이 순차적으로 실행되어야 한다', (WidgetTester tester) async {
      // given (시나리오 설정)
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // 1. 카카오 로그인 성공 가정
      when(mockAuthViewModel.handleKakaoLogin())
          .thenAnswer((_) async => Success(ResultMessage.kakaoAuthSuccess));

      // 2. 토큰 가져오기 성공 가정
      when(mockTokenStorageService.getAccessToken())
          .thenAnswer((_) async => 'mock_access_token');

      // 3. FCM 토큰 전송 성공 가정
      when(mockAuthViewModel.requestFCMTokenAndSendToServer())
          .thenAnswer((_) async => Success(ResultMessage.fcmTokenServerSuccess));

      // when (화면 빌드 및 버튼 탭)
      await tester.pumpWidget(createWidgetUnderTest());

      final loginButton = find.byType(LoginButton);
      await tester.tap(loginButton);

      // 비동기 로직들이 실행될 시간을 줌
      await tester.pumpAndSettle();

      // then (검증)
      // 1. 뷰모델의 handleKakaoLogin이 호출되었는지
      verify(mockAuthViewModel.handleKakaoLogin()).called(1);

      // 2. 스토리지에서 토큰을 가져왔는지 (GetIt을 통해)
      verify(mockTokenStorageService.getAccessToken()).called(1);

      // 3. FCM 토큰 전송 요청을 했는지
      verify(mockAuthViewModel.requestFCMTokenAndSendToServer()).called(1);
    });
  });
}
