import 'package:flutter/foundation.dart';
import 'package:goodnight/models/dhamma_track.dart';
import 'package:goodnight/core/extensions/string_extensions.dart';

/// A collection of Dhamma talks from one Sayadaw (teacher).
@immutable
class SayadawCollection {
  const SayadawCollection({
    required this.index,
    required this.pageTitle,
    required this.pageUrl,
    required this.totalMp3s,
    required this.tracks,
  });

  /// Global index within the full collection list.
  final int index;
  final String pageTitle;
  final String pageUrl;
  final int totalMp3s;
  final List<DhammaTrack> tracks;

  /// Human-readable Sayadaw name extracted from [pageTitle].
  String get displayName => pageTitle.asSayadawName;

  factory SayadawCollection.fromJson(Map<String, dynamic> json, int index) {
    final pageTitle = (json['page_title'] as String?) ?? 'Unknown';
    final sayadawName = pageTitle.asSayadawName;
    final mp3Files = (json['mp3_files'] as List<dynamic>?) ?? [];

    final tracks = mp3Files.asMap().entries.map((entry) {
      return DhammaTrack.fromJson(
        entry.value as Map<String, dynamic>,
        sayadawName: sayadawName,
        collectionIndex: index,
        trackIndex: entry.key,
      );
    }).toList();

    return SayadawCollection(
      index: index,
      pageTitle: pageTitle,
      pageUrl: (json['page_url'] as String?) ?? '',
      totalMp3s: (json['total_mp3s'] as int?) ?? tracks.length,
      tracks: tracks,
    );
  }
}
