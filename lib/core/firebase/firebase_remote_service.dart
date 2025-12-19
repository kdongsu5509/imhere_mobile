import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class FirebaseRemoteService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 12),
      ),
    );

    await _remoteConfig.fetchAndActivate();
  }

  String? get baseUrlOrNull {
    if (_remoteConfig.lastFetchStatus != RemoteConfigFetchStatus.success) {
      return null;
    }
    return _remoteConfig.getValue('base_url').asString();
  }
}
