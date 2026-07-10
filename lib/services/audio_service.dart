import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:goodnight/models/dhamma_track.dart';

/// Wraps [AudioPlayer] (just_audio) and configures the audio session.
///
/// Streams from remote MP3 URLs; only metadata is stored locally.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  DhammaTrack? _currentTrack;

  AudioPlayer get player => _player;
  DhammaTrack? get currentTrack => _currentTrack;

  // ── Streams ────────────────────────────────────────────────────────────────
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<double> get speedStream => _player.speedStream;

  // ── Synchronous getters ────────────────────────────────────────────────────
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  double get speed => _player.speed;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  // ── Playback commands ──────────────────────────────────────────────────────

  Future<void> loadTrack(DhammaTrack track, {bool autoPlay = true}) async {
    _currentTrack = track;
    try {
      await _player.setUrl(track.link);
      if (autoPlay) await _player.play();
    } catch (_) {
      // Network errors surface through playerStateStream.
    }
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> togglePlayPause() =>
      _player.playing ? _player.pause() : _player.play();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> skipForward() async {
    final dur = _player.duration;
    if (dur == null) return;
    final newPos = _player.position + const Duration(seconds: 15);
    await _player.seek(newPos > dur ? dur : newPos);
  }

  Future<void> skipBackward() async {
    final newPos = _player.position - const Duration(seconds: 15);
    await _player.seek(newPos.isNegative ? Duration.zero : newPos);
  }

  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> dispose() => _player.dispose();
}
