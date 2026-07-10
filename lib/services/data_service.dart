import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:goodnight/core/constants/app_constants.dart';
import 'package:goodnight/models/dhamma_track.dart';
import 'package:goodnight/models/sayadaw_collection.dart';

/// Loads, parses, and caches all Dhamma content from the bundled JSON asset.
///
/// The JSON is parsed once at startup; all subsequent reads are in-memory.
/// This enables instant search, offline browsing, and smooth performance
/// even with 20,000+ tracks.
class DataService {
  DataService._();

  static final DataService instance = DataService._();

  List<SayadawCollection> _collections = [];
  List<DhammaTrack> _allTracks = [];
  bool _loaded = false;

  List<SayadawCollection> get collections => _collections;
  List<DhammaTrack> get allTracks => _allTracks;
  bool get isLoaded => _loaded;

  /// Parses the JSON asset into strongly-typed models.
  /// Safe to call multiple times — only executes once.
  Future<void> load() async {
    if (_loaded) return;
    final raw =
        await rootBundle.loadString(AppConstants.dhammaCollectionAsset);
    final data = jsonDecode(raw) as List<dynamic>;
    _collections = data.asMap().entries.map((entry) {
      return SayadawCollection.fromJson(
        entry.value as Map<String, dynamic>,
        entry.key,
      );
    }).toList();
    _allTracks = _collections.expand((c) => c.tracks).toList();
    _loaded = true;
  }

  /// Searches all tracks by label and Sayadaw name.
  /// Supports Myanmar Unicode partial matching.
  List<DhammaTrack> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _allTracks.where((track) {
      return track.label.toLowerCase().contains(q) ||
          track.sayadawName.toLowerCase().contains(q);
    }).toList();
  }

  /// Returns all tracks for a given collection index.
  List<DhammaTrack> tracksForCollection(int collectionIndex) {
    if (collectionIndex < 0 || collectionIndex >= _collections.length) {
      return [];
    }
    return _collections[collectionIndex].tracks;
  }

  /// Finds a track by its composite ID (e.g. "0_5").
  DhammaTrack? findById(String id) {
    try {
      return _allTracks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
