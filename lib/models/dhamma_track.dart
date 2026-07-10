import 'package:flutter/foundation.dart';

/// A single Dhamma talk track — the core data unit of the app.
@immutable
class DhammaTrack {
  const DhammaTrack({
    required this.id,
    required this.label,
    required this.link,
    required this.sayadawName,
    required this.collectionIndex,
    required this.trackIndex,
  });

  final String id;

  /// Display title of the Dhamma talk (may contain Myanmar Unicode).
  final String label;

  /// Remote MP3 URL — audio is streamed, not downloaded.
  final String link;

  /// Display name of the Sayadaw (teacher).
  final String sayadawName;

  /// Index of the parent [SayadawCollection] in the global list.
  final int collectionIndex;

  /// Index of this track within its parent collection.
  final int trackIndex;

  factory DhammaTrack.fromJson(
    Map<String, dynamic> json, {
    required String sayadawName,
    required int collectionIndex,
    required int trackIndex,
  }) {
    return DhammaTrack(
      id: '${collectionIndex}_$trackIndex',
      label: (json['label'] as String?) ?? 'Unknown',
      link: (json['link'] as String?) ?? '',
      sayadawName: sayadawName,
      collectionIndex: collectionIndex,
      trackIndex: trackIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DhammaTrack && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DhammaTrack(id: $id, label: $label)';
}
