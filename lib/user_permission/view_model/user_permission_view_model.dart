import 'package:iamhere/core/di/di_setup.dart';
import 'package:iamhere/user_permission/model/permission_item.dart';
import 'package:iamhere/user_permission/model/permission_state.dart';
import 'package:iamhere/user_permission/service/permission_service_interface.dart';
import 'package:iamhere/user_permission/view_model/permissions.dart';
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
    final newState = [...state];
    bool hasChanged = false;

    for (int i = 0; i < newState.length; i++) {
      final permissions = newState[i];

      final permissionService = _getProperPermissionService(permissions);
      final isGranted = await permissionService.isPermissionGranted();

      if (isGranted) {
        newState[i] = newState[i].copyWith(isGranted: true);
        hasChanged = true;
      }
    }

    if (hasChanged) {
      state = newState;
    }
  }

  /// 특정 권한 요청 로직
  Future<bool> requestPermission(int index) async {
    final targetPermission = state[index];

    final properPermissionService = _getProperPermissionService(
      targetPermission,
    );

    // 권한 요청
    final permissionState = await properPermissionService.requestPermission();

    // PermissionState를 bool로 변환
    final isGranted =
        permissionState == PermissionState.grantedAlways ||
        permissionState == PermissionState.grantedWhenInUse;

    // 상태 업데이트: 리스트의 특정 인덱스만 교체
    final newState = [...state];
    newState[index] = targetPermission.copyWith(isGranted: isGranted);
    state = newState;

    return isGranted;
  }

  /// PermissionItem 타입에 따라 적절한 PermissionService 반환
  PermissionServiceInterface _getProperPermissionService(PermissionItem item) {
    if (item is FcmAlertPermission) {
      return getIt<PermissionServiceInterface>(instanceName: 'fcmAlert');
    } else if (item is LocationPermission) {
      return getIt<PermissionServiceInterface>(instanceName: 'location');
    } else if (item is SmsPermission) {
      return getIt<PermissionServiceInterface>(instanceName: 'sms');
    } else if (item is ContactPermission) {
      return getIt<PermissionServiceInterface>(instanceName: 'contact');
    } else {
      throw ArgumentError('Unknown permission item type: ${item.runtimeType}');
    }
  }
}
