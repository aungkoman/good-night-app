import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodnight/app.dart';
import 'package:goodnight/services/audio_service.dart';
import 'package:goodnight/services/data_service.dart';
import 'package:goodnight/services/media_notification_service.dart';
import 'package:goodnight/services/preferences_service.dart';

/// App entry point.
///
/// Initialization order:
///   1. SharedPreferences
///   2. AudioSession configuration (audio focus, Bluetooth routing)
///   3. JSON asset load + parse
///   4. MediaNotificationService channel registration
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

  // Register the MethodChannel handler so notification button presses
  // are routed to PlayerProvider callbacks
  MediaNotificationService.instance.initialize();

  runApp(const GoodNightApp());
}
