import 'package:flutter/foundation.dart';
import 'package:goodnight/models/dhamma_track.dart';
import 'package:goodnight/models/sayadaw_collection.dart';
import 'package:goodnight/services/data_service.dart';
import 'package:goodnight/services/preferences_service.dart';

/// Exposes library content (collections, recents, favorites) to the UI.
class LibraryProvider extends ChangeNotifier {
  final _data = DataService.instance;
  final _prefs = PreferencesService.instance;

  List<SayadawCollection> get collections => _data.collections;

  List<DhammaTrack> get favorites {
    final ids = _prefs.getFavorites();
    return _data.allTracks.where((t) => ids.contains(t.id)).toList();
  }

  List<DhammaTrack> get recentlyPlayed {
    final ids = _prefs.getRecentlyPlayed();
    final trackMap = {for (final t in _data.allTracks) t.id: t};
    return ids.map((id) => trackMap[id]).whereType<DhammaTrack>().toList();
  }

  Future<void> clearFavorites() async {
    await _prefs.clearFavorites();
    notifyListeners();
  }

  Future<void> clearRecentlyPlayed() async {
    await _prefs.clearRecentlyPlayed();
    notifyListeners();
  }

  /// Call after any mutation (favorite/clear) to push updates to listeners.
  void refresh() => notifyListeners();
}
