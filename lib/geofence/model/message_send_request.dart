import 'package:json_annotation/json_annotation.dart';

part 'message_send_request.g.dart';

@JsonSerializable()
class MessageSendRequest {
  final String message;
  final String receiverNumber;

  MessageSendRequest({required this.message, required this.receiverNumber});

  factory MessageSendRequest.fromJson(Map<String, dynamic> json) =>
      _$MessageSendRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MessageSendRequestToJson(this);
}
