import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodnight/app.dart';
import 'package:goodnight/services/audio_handler.dart';
import 'package:goodnight/services/audio_service.dart';
import 'package:goodnight/services/data_service.dart';
import 'package:goodnight/services/preferences_service.dart';

/// App entry point.
///
/// Initialization order:
///   1. SharedPreferences (synchronous-feeling, fast)
///   2. AudioSession configuration
///   3. AudioHandler for media controls (notification, lock screen)
///   4. JSON asset load + parse (one-time, cached)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar + navigation bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialise all services concurrently
  await Future.wait([
    PreferencesService.instance.initialize(),
    AudioService.instance.initialize(),
    DataService.instance.load(),
  ]);

  // Initialize audio handler for media controls
  final audioHandler = AudioHandler(AudioService.instance.player);
  await AudioService.init(
    builder: () => audioHandler,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'mm.com.software100.goodnight.goodnight.channel.audio',
      androidNotificationChannelName: 'Good Night Audio',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );

  runApp(const GoodNightApp());
}
