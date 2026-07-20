import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:goodnight/models/dhamma_track.dart';
import 'package:goodnight/services/audio_service.dart';
import 'package:goodnight/services/media_notification_service.dart';
import 'package:goodnight/services/preferences_service.dart';
import 'package:goodnight/services/data_service.dart';
import 'package:goodnight/core/constants/app_constants.dart';

enum PlayerStatus { idle, loading, playing, paused, error }

/// Central state manager for all audio playback — the heart of the app.
///
/// Delegates audio I/O to [AudioService] (just_audio) and notification
/// management to [MediaNotificationService] (native Android foreground service
/// via MethodChannel).
class PlayerProvider extends ChangeNotifier {
  PlayerProvider() {
    // Wire notification button taps → our playback methods
    final notif = MediaNotificationService.instance;
    notif.onPlay     = togglePlayPause;
    notif.onPause    = togglePlayPause;
    notif.onNext     = playNext;
    notif.onPrevious = playPrevious;
    _initStreams();
  }

  final _audio = AudioService.instance;
  final _prefs = PreferencesService.instance;
  final _data  = DataService.instance;

  DhammaTrack? _currentTrack;
  PlayerStatus _status  = PlayerStatus.idle;
  Duration     _position = Duration.zero;
  Duration     _duration = Duration.zero;
  double       _speed   = AppConstants.defaultSpeed;
  Set<String>  _favorites = {};
  Timer?       _sleepTimer;
  Timer?       _sleepCountdown;
  int          _sleepMinutes    = 0;
  int          _sleepRemainingSec = 0;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  // ── Getters ────────────────────────────────────────────────────────────────
  DhammaTrack? get currentTrack     => _currentTrack;
  PlayerStatus get status           => _status;
  Duration     get position         => _position;
  Duration     get duration         => _duration;
  double       get speed            => _speed;
  bool get isFavorite =>
      _currentTrack != null && _favorites.contains(_currentTrack!.id);
  int  get sleepMinutes      => _sleepMinutes;
  int  get sleepRemainingSec => _sleepRemainingSec;
  bool get hasSleepTimer     => _sleepMinutes > 0;

  // ── Stream subscriptions ───────────────────────────────────────────────────

  void _initStreams() {
    _subscriptions.addAll([
      _audio.positionStream.listen((pos) {
        _position = pos;
        notifyListeners();
      }),
      _audio.durationStream.listen((dur) {
        _duration = dur ?? Duration.zero;
        notifyListeners();
      }),
      _audio.playerStateStream.listen(_onPlayerStateChanged),
      _audio.speedStream.listen((s) {
        _speed = s;
        notifyListeners();
      }),
    ]);
  }

  void _onPlayerStateChanged(PlayerState state) {
    switch (state.processingState) {
      case ProcessingState.loading:
      case ProcessingState.buffering:
        _status = PlayerStatus.loading;
      case ProcessingState.ready:
        _status = state.playing ? PlayerStatus.playing : PlayerStatus.paused;
        _syncNotification();          // keep notification in sync on play/pause
      case ProcessingState.completed:
        _playNext(auto: true);
        return;
      case ProcessingState.idle:
        _status = PlayerStatus.idle;
    }
    notifyListeners();
  }

  // ── Public commands ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _favorites = _prefs.getFavorites();
    final lastId = _prefs.getLastTrackId();
    final track  = lastId != null
        ? _data.findById(lastId)
        : _data.collections.first.tracks.first;
    await playTrack(track ?? _data.collections.first.tracks.first);
  }

  Future<void> playTrack(DhammaTrack track) async {
    _currentTrack = track;
    _status       = PlayerStatus.loading;
    _position     = Duration.zero;
    _duration     = Duration.zero;
    notifyListeners();

    await _audio.loadTrack(track);
    _syncNotification();          // show notification with new track metadata

    await _prefs.addRecentlyPlayed(track.id);
    await _prefs.saveLastTrack(track.id, 0);
  }

  Future<void> togglePlayPause() => _audio.togglePlayPause();
  Future<void> skipForward()     => _audio.skipForward();
  Future<void> skipBackward()    => _audio.skipBackward();

  Future<void> seek(double ratio) async {
    if (_duration == Duration.zero) return;
    final ms = (ratio * _duration.inMilliseconds).clamp(
      0, _duration.inMilliseconds,
    );
    await _audio.seek(Duration(milliseconds: ms.toInt()));
  }

  Future<void> setSpeed(double speed) => _audio.setSpeed(speed);

  Future<void> toggleFavorite() async {
    if (_currentTrack == null) return;
    await _prefs.toggleFavorite(_currentTrack!.id);
    _favorites = _prefs.getFavorites();
    notifyListeners();
  }

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    _sleepCountdown?.cancel();
    _sleepMinutes    = minutes;
    _sleepRemainingSec = minutes * 60;

    if (minutes > 0) {
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        _audio.pause();
        _sleepMinutes    = 0;
        _sleepRemainingSec = 0;
        notifyListeners();
      });
      _sleepCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_sleepRemainingSec > 0) {
          _sleepRemainingSec--;
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  void playNext()     => _playNext();
  void playPrevious() => _playPrev();

  void _playNext({bool auto = false}) {
    final track = _currentTrack;
    if (track == null) return;
    final collection = _data.collections[track.collectionIndex];
    final nextIndex  = track.trackIndex + 1;
    if (nextIndex < collection.tracks.length) {
      playTrack(collection.tracks[nextIndex]);
    }
  }

  void _playPrev() {
    final track = _currentTrack;
    if (track == null) return;
    if (_position.inSeconds > 3) {
      _audio.seek(Duration.zero);
      return;
    }
    final collection = _data.collections[track.collectionIndex];
    final prevIndex  = track.trackIndex - 1;
    if (prevIndex >= 0) {
      playTrack(collection.tracks[prevIndex]);
    }
  }

  // ── Notification sync ──────────────────────────────────────────────────────

  /// Push current track metadata + playback state to the Android notification.
  void _syncNotification() {
    final track = _currentTrack;
    if (track == null) return;
    MediaNotificationService.instance.updateNotification(
      title:     track.label,
      artist:    track.sayadawName,
      isPlaying: _status == PlayerStatus.playing,
    );
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _sleepCountdown?.cancel();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    MediaNotificationService.instance.stopNotification();
    super.dispose();
  }
}
