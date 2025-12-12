import 'package:flutter/material.dart';
import 'package:iamhere/user_permission/model/permission_item.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_permission_view_model.g.dart';

@riverpod
class UserPermissionViewModel extends _$UserPermissionViewModel {
  // 초기 데이터 (상수처럼 관리)
  final List<PermissionItem> _initialItems = [
    FcmAlertPermission(
      permission: Permission.notification,
      icon: Icons.alarm_on,
      title: "알림",
      shortDesc: "문자 발송 알림",
      detailedDesc:
          "내가 설정한 문자 발송 이벤트가 성공적으로 수행되면 알람을 보내드려요.\n중요한 이벤트와 공지사항도 가장 먼저 받아보세요.",
    ),
    ContactPermission(
      permission: Permission.contacts,
      icon: Icons.contact_phone,
      title: "연락처",
      shortDesc: "연락 보낼 친구 추가",
      detailedDesc:
          "주소록에 있는 친구들을 해당 서비스에 등록할 수 있어요.\n연락처 정보는 서버에 전송 및 저장되지 않으니 안심하세요.",
    ),
    SmsPermission(
      permission: Permission.sms,
      icon: Icons.sms_outlined,
      title: "문자 발송",
      shortDesc: "문자 자동 발송",
      detailedDesc:
          "특정 위치를 지날 때 문자를 자동으로 발송하기 위해 필요해요.\n문자 내용 및 연락처는 서버에 전송 및 저장되지 않아요.",
    ),
    LocationPermission(
      permission: Permission.location,
      icon: Icons.pin_drop_outlined,
      title: "위치 정보",
      shortDesc: "내 위치 확인",
      detailedDesc:
          "ImHere는 위치 기반 문자 발송 서비스에요.\n위치를 바탕으로 문자를 보내기 위해서는 꼭 필요해요\n\n- 앱을 닫아도 정상 동작하도록 항상 허용해주세요.\n- 해당 설정은 설정 앱에서 별도로 지정해주셔야 합니다.\n- 허용하기를 누르시면 우선 앱 사용 중 권한을 요청할게요.\n- 이후 설정을 열테니, 권한 > 위치 > 항상 허용을 눌러주세요.",
    ),
  ];

  @override
  List<PermissionItem> build() {
    // 1. 빌드 시 초기 상태 반환
    // 2. 비동기로 현재 권한 상태 확인 (이미 허용된 권한이 있을 수 있으므로)
    _checkInitialStatuses();
    return _initialItems;
  }

  /// 초기 권한 상태 확인 (앱 시작 시 이미 허용된 권한 체크)
  Future<void> _checkInitialStatuses() async {
    // state 복사본 생성 (직접 수정 불가하므로)
    final newState = [...state];
    bool hasChanged = false;

    for (int i = 0; i < newState.length; i++) {
      final status = await newState[i].permission.status;
      if (status.isGranted || status.isLimited) {
        newState[i] = newState[i].copyWith(isGranted: true);
        hasChanged = true;
      }
    }

    // 변경사항이 있을 때만 상태 업데이트
    if (hasChanged) {
      state = newState;
    }
  }

  /// 특정 권한 요청 로직
  Future<bool> requestPermission(int index) async {
    final targetItem = state[index];

    // 권한 요청
    final status = await targetItem.permission.request();
    final isGranted = status.isGranted || status.isLimited;

    // 상태 업데이트: 리스트의 특정 인덱스만 교체
    final newState = [...state];
    newState[index] = targetItem.copyWith(isGranted: isGranted);
    state = newState;

    return isGranted;
  }
}
