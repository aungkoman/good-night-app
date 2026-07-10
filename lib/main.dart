import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodnight/app.dart';
import 'package:goodnight/services/audio_service.dart';
import 'package:goodnight/services/data_service.dart';
import 'package:goodnight/services/preferences_service.dart';

/// App entry point.
///
/// Initialization order:
///   1. SharedPreferences (synchronous-feeling, fast)
///   2. AudioSession configuration
///   3. JSON asset load + parse (one-time, cached)
///
/// All three run in parallel via [Future.wait].
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

  runApp(const GoodNightApp());
}
