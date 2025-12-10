import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iamhere/core/di/di_setup.dart';
import 'package:iamhere/geofence/service/sms_permission_service.dart';

class SmsService {
  final Ref ref;
  SmsService({required this.ref});
  final SmsPermissionService _permissionService = SmsPermissionService();
  static const MethodChannel _channel = MethodChannel(
    'com.kdongsu5509.iamhere/sms',
  );

  final _sendToMeApiPath = '/api/v1/notification/self';
  final _sendSmsViaServerApiPath = '/api/v1/message';

  Future<void> sendNotificationToMe() async {
    try {
      final dio = getIt.get<Dio>();
      final response = await dio.post(_sendToMeApiPath);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('FCM 알림 요청 성공');
      } else {
        debugPrint('FCM 알림 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('FCM 알림 요청 중 오류 발생: $e');
    }
  }

  /// SMS를 자동으로 전송합니다.
  ///
  /// Android: SEND_SMS 권한이 있으면 자동으로 전송
  /// iOS: SMS 앱을 열어서 사용자가 전송하도록 함
  Future<bool> sendSms({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    try {
      if (phoneNumbers.isEmpty) {
        return false;
      }

      // 전화번호에서 숫자만 추출
      List<String> cleanPhoneNumbers = extractOnlyNumberFromPhoneNumber(
        phoneNumbers,
      );

      if (cleanPhoneNumbers.isEmpty) {
        return false;
      }

      if (Platform.isAndroid) {
        return await _sendSmsAndroid(cleanPhoneNumbers, message);
      } else {
        return await _sendSmsIOS(
          cleanPhoneNumbers,
          message,
        ); //TODO -> Server을 통해 가도록 변경
      }
    } catch (e) {
      debugPrint('SMS 전송 실패: $e');
      return false;
    }
  }

  Future<List<String>> validateAndExtractPhoneNumber(
    List<String> phoneNumbers,
  ) async {
    if (phoneNumbers.isEmpty) {
      return [];
    }
    List<String> cleanPhoneNumbers = extractOnlyNumberFromPhoneNumber(
      phoneNumbers,
    );
    if (cleanPhoneNumbers.isEmpty) {
      return [];
    }

    return cleanPhoneNumbers;
  }

  List<String> extractOnlyNumberFromPhoneNumber(List<String> phoneNumbers) {
    final cleanPhoneNumbers = phoneNumbers
        .map((phone) => phone.replaceAll(RegExp(r'[^\d]'), ''))
        .where((phone) => phone.isNotEmpty)
        .toList();
    return cleanPhoneNumbers;
  }

  /// Android에서 SMS 자동 전송
  Future<bool> _sendSmsAndroid(
    List<String> phoneNumbers,
    String message,
  ) async {
    try {
      // SMS 권한 확인 및 요청
      final hasPermission = await _permissionService
          .requestAndCheckSmsPermission();

      if (!hasPermission) {
        debugPrint('SMS 권한이 없어 자동 전송할 수 없습니다. SMS 앱을 엽니다.');
      }

      try {
        return await _sendSMSViaAndroidMethodChannel(phoneNumbers, message);
      } catch (e) {
        return await _handleFailCaseOfSendingSMS(
          e,
          phoneNumbers,
          message,
          "안드로이드에서 전송 과정에서 오류 발생",
        );
      }
    } catch (e) {
      return await _handleFailCaseOfSendingSMS(
        e,
        phoneNumbers,
        message,
        "안드로이드에서 전송 실패",
      );
    }
  }

  Future<bool> _handleFailCaseOfSendingSMS(
    Object e,
    List<String> phoneNumbers,
    String message,
    String debugMessage,
  ) async {
    debugPrint('$debugMessage: $e');
    return await _sendMultipleSmsOnServer(
      phoneNumbers: phoneNumbers,
      message: message,
    );
  }

  Future<bool> _sendSMSViaAndroidMethodChannel(
    List<String> phoneNumbers,
    String message,
  ) async {
    final result = await _channel.invokeMethod<bool>('sendSms', {
      'phoneNumbers': phoneNumbers,
      'message': message,
    });

    if (result ?? false) {
      await sendNotificationToMe();
    }

    return result ?? false;
  }

  /// iOS에서 SMS 전송 시도 -> 지원 X -> SmsOnServer로 처리
  Future<bool> _sendSmsIOS(List<String> phoneNumbers, String message) async {
    return await _sendMultipleSmsOnServer(
      phoneNumbers: phoneNumbers,
      message: message,
    );
  }

  Future<bool> sendSmsToMultipleRecipients({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    return await sendSms(phoneNumbers: phoneNumbers, message: message);
  }

  Future<bool> _sendSingleSmsOnServer({
    required String phoneNumber,
    required String message,
  }) async {
    final dio = getIt.get<Dio>();

    try {
      final response = await dio.post(
        _sendSmsViaServerApiPath,
        data: {'message': message, 'receiverNumber': phoneNumber},
      );

      final httpStatusCode = response.statusCode;

      final isSuccess = (httpStatusCode == 200 || httpStatusCode == 201);

      // SMS 전송 성공 시 FCM 알림 전송
      if (isSuccess) {
        await sendNotificationToMe();
      }

      return isSuccess;
    } catch (e) {
      debugPrint("서버를 통한 메시지 요청 시도 실패");
      return false;
    }
  }

  Future<bool> _sendMultipleSmsOnServer({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    bool status = true;
    for (int i = 0; i < phoneNumbers.length; i++) {
      var bool = await _sendSingleSmsOnServer(
        phoneNumber: phoneNumbers[i],
        message: message,
      );

      if (bool == false) {
        status = false;
      }
    }

    return status;
  }
}
