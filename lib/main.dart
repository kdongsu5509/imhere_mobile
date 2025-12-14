import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iamhere/common/router/router_provider.dart';
import 'package:iamhere/common/theme/im_here_theme_data_light.dart';
import 'package:iamhere/core/di/di_setup.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'firebase_init_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeAppDependencies();
  runApp(const ProviderScope(child: ImHereApp()));
}

class ImHereApp extends ConsumerStatefulWidget {
  const ImHereApp({super.key});

  @override
  ConsumerState<ImHereApp> createState() => _ImHereAppState();
}

class _ImHereAppState extends ConsumerState<ImHereApp> {
  @override
  Widget build(BuildContext context) {
    final routerConfig = ref.watch(routerProvider);
    return ScreenUtilInit(
      designSize: const Size(402, 874),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'ImHere',
          theme: lightTheme,
          routerConfig: routerConfig,
        );
      },
    );
  }
}

Future<void> _initializeAppDependencies() async {
  final dotenvFileName = 'iam_here_flutter_secret.env';
  final kakaoAppKeyName = 'KAKAO_NATIVE_APP_KEY';
  await dotenv.load(fileName: dotenvFileName);
  // 의존성 주입 초기화
  await configureDependencies();
  // 카카오 로그인 초기화
  KakaoSdk.init(nativeAppKey: dotenv.env[kakaoAppKeyName]);
  // 네이버 지도 초기화
  await _initializeFlutterNaverMap();
  // Firebase 초기화 (Core + Messaging)
  await initializeFirebase();
}

Future<void> _initializeFlutterNaverMap() async {
  await FlutterNaverMap().init(
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID'],
    onAuthFailed: (ex) {
      switch (ex) {
        case NQuotaExceededException(:final message):
          debugPrint("사용량 초과 (message: $message)");
          break;
        case NUnauthorizedClientException() ||
            NClientUnspecifiedException() ||
            NAnotherAuthFailedException():
          debugPrint("인증 실패: $ex");
          break;
      }
    },
  );
}
