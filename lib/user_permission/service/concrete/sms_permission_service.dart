import 'package:iamhere/user_permission/model/permission_state.dart';
import 'package:iamhere/user_permission/service/permission_service_interface.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsPermissionService implements PermissionServiceInterface {
  @override
  Future<PermissionState> requestPermission() async {
    final status = await Permission.sms.request();
    return _mapStatusToPermissionState(status);
  }

  @override
  Future<PermissionState> checkPermissionStatus() async {
    final status = await Permission.sms.status;
    return _mapStatusToPermissionState(status);
  }

  @override
  Future<bool> isPermissionGranted() async {
    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// SMS 권한 요청 및 확인
  /// 권한이 없으면 요청하고, 최종 상태를 반환합니다.
  Future<bool> requestAndCheckSmsPermission() async {
    final currentStatus = await Permission.sms.status;

    if (currentStatus.isGranted) {
      return true;
    }

    if (currentStatus.isDenied) {
      final requestedStatus = await Permission.sms.request();
      return requestedStatus.isGranted;
    }

    if (currentStatus.isPermanentlyDenied) {
      // 영구적으로 거부된 경우 설정으로 이동
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// PermissionStatus를 PermissionState로 매핑
  PermissionState _mapStatusToPermissionState(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return PermissionState.grantedAlways;
    } else if (status.isPermanentlyDenied) {
      return PermissionState.permanentlyDenied;
    } else if (status.isRestricted) {
      return PermissionState.restricted;
    } else {
      return PermissionState.denied;
    }
  }
}
