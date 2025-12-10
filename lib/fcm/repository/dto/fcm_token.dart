import 'package:json_annotation/json_annotation.dart';

part 'fcm_token.g.dart';

/// FCM 토큰 등록 요청 모델
@JsonSerializable()
class FcmToken {
  @JsonKey(name: 'fcmToken')
  final String fcmToken;

  FcmToken({required this.fcmToken});

  Map<String, dynamic> toJson() => _$FcmTokenToJson(this);
}
