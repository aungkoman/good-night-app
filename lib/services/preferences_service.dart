import 'package:shared_preferences/shared_preferences.dart';
import 'package:goodnight/core/constants/app_constants.dart';

/// Persists user data (favorites, recently played, last position) locally.
class PreferencesService {
  PreferencesService._();

  static final PreferencesService instance = PreferencesService._();

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Favorites ──────────────────────────────────────────────────────────────

  Set<String> getFavorites() =>
      (_prefs.getStringList(AppConstants.keyFavorites) ?? []).toSet();

  bool isFavorite(String trackId) => getFavorites().contains(trackId);

  Future<void> toggleFavorite(String trackId) async {
    final favorites = getFavorites();
    favorites.contains(trackId)
        ? favorites.remove(trackId)
        : favorites.add(trackId);
    await _prefs.setStringList(
        AppConstants.keyFavorites, favorites.toList());
  }

  Future<void> clearFavorites() =>
      _prefs.remove(AppConstants.keyFavorites);

  // ── Recently Played ────────────────────────────────────────────────────────

  List<String> getRecentlyPlayed() =>
      _prefs.getStringList(AppConstants.keyRecentlyPlayed) ?? [];

  Future<void> addRecentlyPlayed(String trackId) async {
    final recent = getRecentlyPlayed();
    recent.remove(trackId);
    recent.insert(0, trackId);
    if (recent.length > AppConstants.maxRecentlyPlayed) {
      recent.removeRange(AppConstants.maxRecentlyPlayed, recent.length);
    }
    await _prefs.setStringList(AppConstants.keyRecentlyPlayed, recent);
  }

  Future<void> clearRecentlyPlayed() =>
      _prefs.remove(AppConstants.keyRecentlyPlayed);

  // ── Last played track ──────────────────────────────────────────────────────

  Future<void> saveLastTrack(String trackId, int positionMs) async {
    await _prefs.setString(AppConstants.keyLastTrackId, trackId);
    await _prefs.setInt(AppConstants.keyLastPosition, positionMs);
  }

  String? getLastTrackId() => _prefs.getString(AppConstants.keyLastTrackId);

  int getLastPositionMs() =>
      _prefs.getInt(AppConstants.keyLastPosition) ?? 0;
}
