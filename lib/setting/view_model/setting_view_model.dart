import 'package:get_it/get_it.dart';
import 'package:iamhere/user_permission/service/permission_service_interface.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'setting_view_model_state.dart';

part 'setting_view_model.g.dart';

@riverpod
class SettingViewModel extends _$SettingViewModel {
  late final PermissionServiceInterface _fcmService;
  late final PermissionServiceInterface _smsService;
  late final PermissionServiceInterface _locationService;

  @override
  Future<SettingViewModelState> build() async {
    _fcmService = GetIt.I<PermissionServiceInterface>(instanceName: 'fcmAlert');
    _smsService = GetIt.I<PermissionServiceInterface>(instanceName: 'sms');
    _locationService = GetIt.I<PermissionServiceInterface>(
      instanceName: 'location',
    );

    return _fetchInitialState();
  }

  Future<SettingViewModelState> _fetchInitialState() async {
    final push = await _fcmService.checkPermissionStatus();
    final sms = await _smsService.checkPermissionStatus();
    final location = await _locationService.checkPermissionStatus();

    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;
    final versionString = buildNumber.isEmpty
        ? 'v$version'
        : 'v$version+$buildNumber';

    return SettingViewModelState(
      pushPermission: push,
      smsPermission: sms,
      locationPermission: location,
      appVersion: versionString,
    );
  }

  Future<void> refreshPermissions() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchInitialState());
  }
}
