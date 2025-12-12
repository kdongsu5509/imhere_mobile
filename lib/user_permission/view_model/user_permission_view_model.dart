import 'package:iamhere/user_permission/model/permission_item.dart';
import 'package:iamhere/user_permission/view_model/permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_permission_view_model.g.dart';

@riverpod
class UserPermissionViewModel extends _$UserPermissionViewModel {
  @override
  List<PermissionItem> build() {
    _checkInitialStatuses();
    return permissions;
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
