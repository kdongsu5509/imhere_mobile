import 'package:flutter/material.dart';
import 'package:iamhere/user_permission/model/items/contact_permission_item.dart';
import 'package:iamhere/user_permission/model/items/fcm_permision_item.dart';
import 'package:iamhere/user_permission/model/items/location_permission_item.dart';
import 'package:iamhere/user_permission/model/items/sms_permission_item.dart';
import 'package:iamhere/user_permission/model/permission_item.dart';

final List<PermissionItem> permissions = [
  FcmAlertPermissionItem(
    icon: Icons.alarm_on,
    title: "알림",
    shortDesc: "문자 발송 알림",
    detailedDesc: _createDesc(_alertPermissionDesc),
  ),
  ContactPermissionItem(
    icon: Icons.contact_phone,
    title: "연락처",
    shortDesc: "연락 보낼 친구 추가",
    detailedDesc: _createDesc(_contactPermissionDesc),
  ),
  SmsPermissionItem(
    icon: Icons.sms_outlined,
    title: "문자 발송",
    shortDesc: "문자 자동 발송",
    detailedDesc: _createDesc(_smsPermissionDesc),
  ),
  LocationPermissionItem(
    icon: Icons.pin_drop_outlined,
    title: "위치 정보",
    shortDesc: "내 위치 확인",
    detailedDesc: _createDesc(_locationPermissionDesc),
  ),
];

String _createDesc(List<String> description) {
  StringBuffer sb = StringBuffer();

  for (var x in description) {
    sb.write(x);
    sb.write('\n');
  }

  return sb.toString();
}

final _alertPermissionDesc = [
  '내가 설정한 문자 발송 이벤트가 성공적으로 수행되면 알람을 보내드려요.',
  '중요한 이벤트와 공지사항도 가장 먼저 받아보세요."',
];

final _contactPermissionDesc = [
  '주소록에 있는 친구들을 해당 서비스에 등록할 수 있어요.',
  '연락처 정보는 서버에 전송 및 저장되지 않으니 안심하세요.',
];

final _smsPermissionDesc = [
  '특정 위치를 지날 때 문자를 자동으로 발송하기 위해 필요해요.',
  '문자 내용 및 연락처는 서버에 전송 및 저장되지 않아요.',
];

final _locationPermissionDesc = [
  'ImHere는 위치 기반 문자 발송 서비스에요.',
  '위치를 바탕으로 문자를 보내기 위해서는 꼭 필요해요\n',
  '- 앱을 닫아도 정상 동작하도록 항상 허용해주세요.',
  '- 해당 설정은 설정 앱에서 별도로 지정해주셔야 합니다.',
  '- 허용하기를 누르시면 우선 앱 사용 중 권한을 요청할게요.',
  '- 이후 설정을 열테니, 권한 > 위치 > 항상 허용을 눌러주세요.',
];
