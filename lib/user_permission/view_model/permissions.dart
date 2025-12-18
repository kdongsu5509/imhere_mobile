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
  '[수집 데이터] 기기 알림 토큰',
  '[수집 시점] 사용자가 알림을 허용할 때',
  '[사용 목적] 문자 발송 성공/실패 알림 전송',
  '',
  '내가 설정한 문자 발송 이벤트가 성공적으로 수행되면 알람을 보내드려요.',
  '중요한 이벤트와 공지사항도 가장 먼저 받아보세요.',
];

final _contactPermissionDesc = [
  '[수집 데이터] 주소록의 이름과 전화번호',
  '[수집 시점] 문자 발송 대상을 선택할 때',
  '[사용 목적] 문자를 보낼 친구를 선택하기 위함',
  '[데이터 저장] 기기 내에만 저장되며, 서버로 전송되지 않습니다',
  '',
  '주소록에 있는 친구들을 해당 서비스에 등록할 수 있어요.',
  '연락처 정보는 오직 문자 발송 대상을 선택할 때만 사용됩니다.',
];

final _locationPermissionDesc = [
  '[수집 데이터] 위치 정보 (GPS, 네트워크 기반)',
  '[수집 시점] 앱이 닫혀있거나 사용하지 않을 때도 백그라운드에서 수집',
  '[사용 목적] 지정된 위치를 지날 때 자동으로 문자를 발송하기 위함',
  '[데이터 저장] 위치 정보는 기기에만 저장되며, 서버로 전송되지 않습니다',
  '',
  'ImHere는 위치 기반 문자 발송 서비스입니다.',
  '백그라운드에서 위치를 추적하여 설정된 장소를 지날 때 자동으로 문자를 보냅니다.',
  '',
  '설정 방법:',
  '1. "허용하기"를 누르면 먼저 "앱 사용 중" 권한을 요청합니다',
  '2. 이후 설정으로 이동하여 "항상 허용"으로 변경해주세요',
  '3. 경로: 설정 > 권한 > 위치 > 항상 허용',
];
