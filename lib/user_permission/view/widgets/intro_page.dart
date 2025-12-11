import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iamhere/common/view_component/black_button.dart';

/// 권한 설정 인트로 페이지 위젯
class IntroPage extends StatelessWidget {
  final VoidCallback onNext;

  const IntroPage({super.key, required this.onNext});

  final _appLogoPosition = 'assets/images/app_logo.png';
  final _introTitle = '만나서 반가워요!';
  final _permissionRequestDescription = 'ImHere의 원활한 동작을 위해\n몇 가지 권한 설정이 필요합니다';
  final _startButtonText = '시작하기';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset(_appLogoPosition, width: 120.w),
          SizedBox(height: 32.h),
          Text(
            _introTitle,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 32.h),
          Text(
            _permissionRequestDescription,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.sp),
          ),
          const Spacer(),
          BlackButton(onPressed: onNext, message: _startButtonText),
        ],
      ),
    );
  }
}
