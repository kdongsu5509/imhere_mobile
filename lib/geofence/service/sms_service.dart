import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iamhere/core/di/di_setup.dart';

class SmsService {
  final Ref ref;
  SmsService({required this.ref});

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

  /// SMS 발송을 서버에 자동으로 요청합니다
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

      return await sendSmsToMultipleRecipients(
        phoneNumbers: cleanPhoneNumbers,
        message: message,
      );
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
