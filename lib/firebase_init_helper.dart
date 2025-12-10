import 'dart:isolate'; // Isolate 에러 처리 사용
import 'dart:ui'; // PlatformDispatcher 사용

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import 'fcm/fcm_message_handler.dart';
import 'firebase_options.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  _enrollFirebaseMessagingHandler();
  _initFirebaseCrashlytics();
}

void _enrollFirebaseMessagingHandler() {
  // FCM 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // FCM 포그라운드 메시지 리스너 설정
  setupForegroundMessageListener();
  // FCM 메시지 탭 핸들러 설정
  setupMessageTapHandler();
}

void _initFirebaseCrashlytics() {
  var firebaseCrashlytics = FirebaseCrashlytics.instance;

  _enrollSynchronousErrorHandler(firebaseCrashlytics);
  _enrollAsynchronousErrorHandler(firebaseCrashlytics);
  _enrollIsolateErrorHandler(firebaseCrashlytics);
}

void _enrollSynchronousErrorHandler(FirebaseCrashlytics firebaseCrashlytics) {
  FlutterError.onError = (errorDetails) {
    firebaseCrashlytics.recordFlutterFatalError(errorDetails);
  };
}

void _enrollAsynchronousErrorHandler(FirebaseCrashlytics firebaseCrashlytics) {
  PlatformDispatcher.instance.onError = (error, stack) {
    firebaseCrashlytics.recordError(error, stack, fatal: true);
    return true;
  };
}

void _enrollIsolateErrorHandler(FirebaseCrashlytics firebaseCrashlytics) {
  Isolate.current.addErrorListener(
    RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await firebaseCrashlytics.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
        fatal: true,
      );
    }).sendPort,
  );
}
