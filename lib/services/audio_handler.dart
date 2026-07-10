import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:goodnight/models/dhamma_track.dart';

/// Audio handler for media controls in notification, lock screen, and background.
///
/// This integrates with the Android/iOS media session to provide:
/// - Play/pause/skip controls in notification
/// - Lock screen media controls
/// - Background playback
/// - Integration with other apps (headphones, Bluetooth, etc.)
class AudioHandler extends BaseAudioHandler {
  final AudioPlayer _player;

  AudioHandler(this._player) {
    _setupAudioHandler();
  }

  void _setupAudioHandler() {
    // Set up media item callbacks
    playbackState.add(_player.playbackState);

    _player.playbackEventStream.listen((event) {
      final state = playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: const [0, 2, 4],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState] ?? AudioProcessingState.idle,
        repeatMode: _player.loopMode == LoopMode.one
            ? AudioServiceRepeatMode.one
            : AudioServiceRepeatMode.off,
        shuffleMode: _player.shuffleModeEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      );
      playbackState.add(state);
    });
  }

  /// Load a track and update the media notification
  Future<void> loadTrack(DhammaTrack track) async {
    final mediaItem = MediaItem(
      id: track.id,
      title: track.label,
      artist: track.sayadawName,
      artUri: null, // Could add artwork URL if available
    );

    mediaItem.add(mediaItem);
    await _player.setUrl(track.link);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    // This will be handled by PlayerProvider
  }

  @override
  Future<void> skipToPrevious() async {
    // This will be handled by PlayerProvider
  }

  @override
  Future<void> fastForward() => _player.seek(
        _player.position + const Duration(seconds: 15),
      );

  @override
  Future<void> rewind() => _player.seek(
        _player.position - const Duration(seconds: 15),
      );

  @override
  Future<void> stop() => _player.stop();
}
