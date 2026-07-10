/// App-wide constants — single source of truth for magic values.
abstract final class AppConstants {
  // ── Asset paths ────────────────────────────────────────────────────────────
  static const String dhammaCollectionAsset =
      'assets/data/dhamma_collection.json';

  // ── Playback ───────────────────────────────────────────────────────────────
  static const double defaultSpeed = 1.0;
  static const List<double> speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
  static const Duration skipDuration = Duration(seconds: 15);

  // ── Sleep timer (minutes, 0 = off) ────────────────────────────────────────
  static const List<int> sleepTimerMinutes = [0, 15, 30, 45, 60];

  // ── SharedPreferences keys ────────────────────────────────────────────────
  static const String keyFavorites = 'favorites';
  static const String keyRecentlyPlayed = 'recently_played';
  static const String keyLastTrackId = 'last_track_id';
  static const String keyLastPosition = 'last_position_ms';

  // ── UI metrics ────────────────────────────────────────────────────────────
  static const double artworkSize = 270.0;
  static const double miniPlayerHeight = 68.0;
  static const int maxRecentlyPlayed = 30;
  static const int searchDebounceMs = 300;
}
