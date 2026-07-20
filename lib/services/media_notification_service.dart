import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bidirectional bridge between Flutter and [GoodNightMediaService] (Android).
///
/// Flutter → Native:
///   [updateNotification] → starts/updates the foreground service notification
///   [stopNotification]   → stops the foreground service
///
/// Native → Flutter (notification button taps / hardware media keys):
///   [onPlay] | [onPause] | [onNext] | [onPrevious] — wired by [PlayerProvider]
class MediaNotificationService {
  MediaNotificationService._();

  static final instance = MediaNotificationService._();

  static const _channel = MethodChannel('goodnight/media');

  // ── Callbacks (set by PlayerProvider) ─────────────────────────────────────
  VoidCallback? onPlay;
  VoidCallback? onPause;
  VoidCallback? onNext;
  VoidCallback? onPrevious;

  // ── Initialisation ─────────────────────────────────────────────────────────

  /// Call once at startup (before [PlayerProvider.initialize]).
  void initialize() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'play':
        onPlay?.call();
      case 'pause':
        onPause?.call();
      case 'next':
        onNext?.call();
      case 'previous':
        onPrevious?.call();
    }
  }

  // ── Commands ───────────────────────────────────────────────────────────────

  /// Push track metadata + playback state to the Android notification.
  ///
  /// This starts [GoodNightMediaService] as a foreground service on the first
  /// call, and simply updates the notification on subsequent calls.
  Future<void> updateNotification({
    required String title,
    required String artist,
    required bool isPlaying,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('updateNotification', {
        'title': title,
        'artist': artist,
        'isPlaying': isPlaying,
      });
    } on PlatformException {
      // Service unavailable — fail silently (e.g. during cold start)
    }
  }

  /// Remove the notification and stop the foreground service.
  Future<void> stopNotification() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('stopNotification');
    } on PlatformException {
      // Ignore
    }
  }
}
