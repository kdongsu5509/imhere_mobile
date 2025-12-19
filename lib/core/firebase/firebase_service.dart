import 'package:firebase_core/firebase_core.dart';
import 'package:iamhere/core/firebase/firebase_cloud_message_service.dart';
import 'package:iamhere/core/firebase/firebase_crashlytics_service.dart';

import '../../firebase_options.dart';
import 'firebase_remote_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseRemoteService remoteConfig = FirebaseRemoteService();
  final FirebaseCrashlyticsService crashlyticsService = FirebaseCrashlyticsService();
  final FirebaseCloudMessageService fcmService = FirebaseCloudMessageService();

  Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    await crashlyticsService.initialize();
    await fcmService.initialize();
    await remoteConfig.initialize();
  }
}
