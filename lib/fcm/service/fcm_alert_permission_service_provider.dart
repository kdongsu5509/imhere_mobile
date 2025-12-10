import 'package:iamhere/fcm/service/fcm_alert_permission_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fcm_alert_permission_service_provider.g.dart';

@riverpod
FcmAlertPermissionService fcmAlertPermissionService(Ref ref) {
  return FcmAlertPermissionService();
}
