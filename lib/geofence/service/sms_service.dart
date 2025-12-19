import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iamhere/core/di/di_setup.dart';
import 'package:iamhere/geofence/model/message_send_request.dart';
import 'package:iamhere/geofence/model/multiple_message_send_request.dart';

class SmsService {
  final Ref ref;
  SmsService({required this.ref});

  final _sendToMeApiPath = '/api/v1/notification/self';
  final _sendSmsToSingleApiPath = '/api/v1/message/send';
  final _sendSmsToMultiApiPath = '/api/v1/message/multipleSend';

  /// FCM 관련 요청 로직
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
      List<String> cleanPhoneNumbers = _extractOnlyNumberFromPhoneNumber(
        phoneNumbers,
      );

      if (cleanPhoneNumbers.isEmpty) {
        return false;
      }

      if (cleanPhoneNumbers.length == 1) {
        return await _sendSingleSms(
          phoneNumber: cleanPhoneNumbers[0],
          message: message,
        );
      } else {
        return await _sendMultiSms(
          phoneNumbers: cleanPhoneNumbers,
          message: message,
        );
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
    List<String> cleanPhoneNumbers = _extractOnlyNumberFromPhoneNumber(
      phoneNumbers,
    );
    if (cleanPhoneNumbers.isEmpty) {
      return [];
    }

    return cleanPhoneNumbers;
  }

  List<String> _extractOnlyNumberFromPhoneNumber(List<String> phoneNumbers) {
    final cleanPhoneNumbers = phoneNumbers
        .map((phone) => phone.replaceAll(RegExp(r'[^\d]'), ''))
        .where((phone) => phone.isNotEmpty)
        .toList();
    return cleanPhoneNumbers;
  }

  Future<bool> _sendSingleSms({
    required String phoneNumber,
    required String message,
  }) async {
    final dio = getIt.get<Dio>();

    try {
      final response = await dio.post(
        _sendSmsToSingleApiPath,
        data: MessageSendRequest(
          message: message,
          receiverNumber: phoneNumber,
        ).toJson(),
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

  Future<bool> _sendMultiSms({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    final dio = getIt.get<Dio>();

    final List<MessageSendRequest> requests = [];
    for (var phoneNumber in phoneNumbers) {
      requests.add(
        MessageSendRequest(message: message, receiverNumber: phoneNumber),
      );
    }

    try {
      final response = await dio.post(
        _sendSmsToMultiApiPath,
        data: MultipleMessageSendRequest(requests: requests).toJson(),
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
}
