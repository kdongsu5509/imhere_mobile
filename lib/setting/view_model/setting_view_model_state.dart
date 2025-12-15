import 'package:iamhere/user_permission/model/permission_state.dart';

class SettingViewModelState {
  final PermissionState pushPermission;
  final PermissionState smsPermission;
  final PermissionState locationPermission;
  final String appVersion;

  SettingViewModelState({
    this.pushPermission = PermissionState.denied,
    this.smsPermission = PermissionState.denied,
    this.locationPermission = PermissionState.denied,
    this.appVersion = '',
  });

  SettingViewModelState copyWith({
    PermissionState? pushPermission,
    PermissionState? smsPermission,
    PermissionState? locationPermission,
    String? appVersion,
  }) {
    return SettingViewModelState(
      pushPermission: pushPermission ?? this.pushPermission,
      smsPermission: smsPermission ?? this.smsPermission,
      locationPermission: locationPermission ?? this.locationPermission,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
