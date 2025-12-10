import 'package:json_annotation/json_annotation.dart';

part 'login_request_dto.g.dart';

@JsonSerializable()
class LoginReqeustDto {
  final String provider;
  final String idToken;

  LoginReqeustDto({required this.provider, required this.idToken});

  Map<String, dynamic> toJson() => _$LoginReqeustDtoToJson(this);
}
