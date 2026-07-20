import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:goodnight/models/dhamma_track.dart';

/// Audio handler for media controls in notification, lock screen, and background.
///
/// This integrates with the Android/iOS media session to provide:
/// - Play/pause/skip controls in the notification shade
/// - Lock screen media controls
/// - Background playback (audio continues when app is backgrounded)
/// - Integration with headphones, Bluetooth, car audio, etc.
class GoodNightAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;

  /// Callbacks wired up by [PlayerProvider] after construction.
  VoidCallback? onSkipNext;
  VoidCallback? onSkipPrevious;

  GoodNightAudioHandler(this._player) {
    _forwardPlaybackState();
  }

  // ── Internal setup ─────────────────────────────────────────────────────────

  void _forwardPlaybackState() {
    _player.playbackEventStream.listen((event) {
      final isPlaying = _player.playing;

      playbackState.add(
        PlaybackState(
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.rewind,
            if (isPlaying) MediaControl.pause else MediaControl.play,
            MediaControl.fastForward,
            MediaControl.skipToNext,
          ],
          // Compact notification shows prev, play/pause, next
          androidCompactActionIndices: const [0, 2, 4],
          processingState: {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState] ??
              AudioProcessingState.idle,
          playing: isPlaying,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: 0,
        ),
      );
    });
  }

  // ── Track loading ──────────────────────────────────────────────────────────

  /// Call this whenever a new track is loaded so the notification updates.
  void updateTrack(DhammaTrack track) {
    mediaItem.add(
      MediaItem(
        id: track.id,
        title: track.label,
        artist: track.sayadawName,
        // Duration will be updated once known
        duration: _player.duration,
      ),
    );
  }

  // ── BaseAudioHandler overrides ────────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() async => onSkipNext?.call();

  @override
  Future<void> skipToPrevious() async => onSkipPrevious?.call();

  @override
  Future<void> fastForward() async {
    final dur = _player.duration;
    if (dur == null) return;
    final newPos = _player.position + const Duration(seconds: 15);
    await _player.seek(newPos > dur ? dur : newPos);
  }

  @override
  Future<void> rewind() async {
    final newPos = _player.position - const Duration(seconds: 15);
    await _player.seek(newPos.isNegative ? Duration.zero : newPos);
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);
}
