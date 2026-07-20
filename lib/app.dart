import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodnight/core/theme/app_theme.dart';
import 'package:goodnight/providers/library_provider.dart';
import 'package:goodnight/providers/player_provider.dart';
import 'package:goodnight/services/audio_handler.dart';
import 'package:goodnight/widgets/common/app_scaffold.dart';

/// Root widget — provides the app theme and global state providers.
class GoodNightApp extends StatelessWidget {
  const GoodNightApp({super.key, required this.audioHandler});

  final GoodNightAudioHandler audioHandler;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerProvider>(
          create: (_) => PlayerProvider(audioHandler: audioHandler)..initialize(),
        ),
        ChangeNotifierProvider<LibraryProvider>(
          create: (_) => LibraryProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Good Night',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AppScaffold(),
      ),
    );
  }
}
