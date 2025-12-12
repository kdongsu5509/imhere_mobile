import 'package:iamhere/user_permission/model/permission_state.dart';
import 'package:iamhere/user_permission/service/permission_service_interface.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactPermissionService implements PermissionServiceInterface {
  @override
  Future<PermissionState> checkPermissionStatus() {
    // TODO: implement checkPermissionStatus
    throw UnimplementedError();
  }

  @override
  Future<bool> isPermissionGranted() {
    // TODO: implement isPermissionGranted
    throw UnimplementedError();
  }

  @override
  Future<PermissionState> requestPermission() {
    // TODO: implement requestPermission
    throw UnimplementedError();
  }

  Future<void> checkPermission() async {
    final status = await Permission.contacts.request();
    if (status.isGranted || status.isLimited) {
      return;
    }

    if (status.isDenied) {
      throw Exception("연락처 권한을 허용해주세요!");
    }

    if (status.isRestricted) {
      throw Exception("사용자 기기의 정책으로 인해 접근이 불가능 합니다. 설정에서 정책을 변경해주세요");
    }

    if (status.isPermanentlyDenied) {
      throw Exception("연락처 권한이 영구적으로 거부되었습니다. 설정에서 수동으로 허용해주세요.");
    }
  }
}
