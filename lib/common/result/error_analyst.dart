import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ErrorAnalyst {
  static Future<void> log(String message, StackTrace? stackTrace) async {
    await FirebaseCrashlytics.instance.recordError(
      Exception(message),
      stackTrace,
      reason: 'Result.Failure Handled',
      fatal: false,
    );
  }
}
