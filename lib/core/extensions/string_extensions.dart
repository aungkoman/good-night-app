extension StringX on String {
  /// Extracts a clean, display-ready Sayadaw name from a raw page title.
  /// e.g. "vipassana teaching mp3 audio by Maha Bodhi Myaing Sayadaw"
  ///      → "Maha Bodhi Myaing Sayadaw"
  String get asSayadawName {
    // Pattern 1: "... by XYZ ..."
    final byPattern = RegExp(
      r'by\s+(.+?)(?:\s*\||\s*$)',
      caseSensitive: false,
    );
    final match = byPattern.firstMatch(this);
    if (match != null) {
      return match
          .group(1)!
          .replaceAll(RegExp(r'\s*mp3.*$', caseSensitive: false), '')
          .replaceAll(RegExp(r'\s*audio.*$', caseSensitive: false), '')
          .replaceAll(RegExp(r'\s*teaching.*$', caseSensitive: false), '')
          .replaceAll(RegExp(r'\s*dhamma.*$', caseSensitive: false), '')
          .trim();
    }
    // Pattern 2: "Name | extra"  or just the raw title
    return split('|').first.trim();
  }

  /// Truncates to [maxLength] chars and appends '…' if needed.
  String truncated([int maxLength = 60]) =>
      length > maxLength ? '${substring(0, maxLength - 1)}…' : this;
}

extension DurationX on Duration {
  /// Formats as mm:ss or h:mm:ss.
  String get formatted {
    final h = inHours;
    final m = inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
