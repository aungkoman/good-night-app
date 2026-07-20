import 'package:audio_service/audio_service.dart' as audio_svc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodnight/app.dart';
import 'package:goodnight/services/audio_handler.dart';
import 'package:goodnight/services/audio_service.dart' as app_audio;
import 'package:goodnight/services/data_service.dart';
import 'package:goodnight/services/preferences_service.dart';

/// App entry point.
///
/// Initialization order:
///   1. SharedPreferences (synchronous-feeling, fast)
///   2. AudioSession configuration
///   3. JSON asset load + parse (one-time, cached)
///   4. AudioHandler wrapped in audio_service.init() for media-session controls
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
    app_audio.AudioService.instance.initialize(),
    DataService.instance.load(),
  ]);

  // Wrap in AudioService.init so the OS media session is registered.
  // The handler MUST be created inside the builder lambda.
  final audioHandler = await audio_svc.AudioService.init<GoodNightAudioHandler>(
    builder: () => GoodNightAudioHandler(app_audio.AudioService.instance.player),
    config: audio_svc.AudioServiceConfig(
      androidNotificationChannelId:
          'mm.com.software100.goodnight.goodnight.channel.audio',
      androidNotificationChannelName: 'Good Night Audio',
      // androidNotificationOngoing + androidStopForegroundOnPause:false are
      // mutually exclusive — audio_service asserts against that combination.
      // androidStopForegroundOnPause:false keeps the service in foreground
      // (which also keeps the notification alive), so `ongoing` is not needed.
      androidShowNotificationBadge: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidStopForegroundOnPause: false,
    ),
  );

  runApp(GoodNightApp(audioHandler: audioHandler));
}
