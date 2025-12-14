import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iamhere/auth/service/auth_state_provider.dart';
import 'package:iamhere/auth/service/token_storage_service.dart';
import 'package:iamhere/auth/view/component/login_button.dart';
import 'package:iamhere/auth/view/component/login_button_info.dart';
import 'package:iamhere/auth/view/component/right_content_widget.dart';
import 'package:iamhere/auth/view_model/auth_view_model.dart';
import 'package:iamhere/common/result/result.dart';
import 'package:iamhere/core/di/di_setup.dart';

class AuthView extends ConsumerStatefulWidget {
  final AuthViewModel _authViewModel;
  const AuthView(this._authViewModel, {super.key});

  @override
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  final String _appTitle = 'Imhere';
  final String _subTitle = '정해진 장소를 지나면 문자를 보낼게요!';
  final String _authorizationRequestDescription = '앱 사용을 위해 다음 권한이 필요해요';
  final List<String> _authorizationElements = ['위치', 'SMS', '연락처', '백그라운드 위치'];

  /// 로그인 처리 로직
  Future<void> _handleLogin() async {
    var result = await widget._authViewModel.handleKakaoLogin();

    if (!mounted) return;

    // 로그인 결과 처리
    result.handle(context: context, onSuccess: (data) {}, showSnackBar: false);

    // 토큰 확인 및 FCM 토큰 서버 전송
    final tokenStorage = getIt<TokenStorageService>();
    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty && mounted) {
      var fcmResult = await widget._authViewModel
          .requestFCMTokenAndSendToServer();

      if (!mounted) return;

      fcmResult.handle(
        context: context,
        onSuccess: (data) {
          if (mounted) {
            // authStateProvider를 invalidate하여 최신 인증 상태 반영
            // GoRouter의 redirect 로직이 자동으로 /geofence로 이동시킴
            ref.invalidate(authStateProvider);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 65.h),
            buildAppTitle(context),
            SizedBox(height: 6.h),
            buildAppSubTitle(context),
            SizedBox(height: 270.h),
            consistLoginButtons(context), // ref 전달 불필요 (class 안에 있으므로)
            SizedBox(height: 40.h),
            buildAuthorizationRequestDescription(context),
            SizedBox(height: 10.h),
            consistAuthenticationElements(context),
          ],
        ),
      ),
    );
  }

  // ... (Title, SubTitle 메서드는 동일) ...

  Text buildAppTitle(BuildContext context) {
    return Text(
      _appTitle,
      style: Theme.of(
        context,
      ).textTheme.headlineLarge?.copyWith(fontSize: 58.sp),
    );
  }

  Text buildAppSubTitle(BuildContext context) {
    return Text(
      _subTitle,
      style: Theme.of(
        context,
      ).textTheme.headlineMedium?.copyWith(fontSize: 20.sp),
    );
  }

  Widget consistLoginButtons(BuildContext context) {
    return Column(
      children: [
        LoginButton(
          buttonInfo: LoginInfoData.kakao,
          // 5. [핵심] 함수 호출()이 아니라, 함수 자체를 넘겨야 합니다.
          onPressed: () async {
            await _handleLogin();
          },
        ),
      ],
    );
  }

  // ... (나머지 메서드 동일) ...
  Text buildAuthorizationRequestDescription(BuildContext context) {
    return Text(
      _authorizationRequestDescription,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Row consistAuthenticationElements(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _authorizationElements
          .map((right) => rightContentWidget(context: context, right: right))
          .toList(),
    );
  }
}
