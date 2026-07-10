import 'package:flutter/material.dart';

/// Central color palette for Good Night — calm, dark, and premium.
abstract final class AppColors {
  // ── Background layers ──────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF12182B);
  static const Color card = Color(0xFF1A2238);
  static const Color cardElevated = Color(0xFF202A42);

  // ── Primary accent — soft violet ───────────────────────────────────────────
  static const Color primary = Color(0xFF8B7CF6);
  static const Color primaryLight = Color(0xFFC4B5FD);
  static const Color primaryDark = Color(0xFF5B4BA6);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color textDisabled = Color(0xFF4A5568);

  // ── Functional ─────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFC8181);
  static const Color success = Color(0xFF68D391);
  static const Color divider = Color(0xFF1E2A40);
  static const Color miniPlayerBg = Color(0xFF141C2F);

  // ── Artwork gradients — muted tones for calm, meditative feel ──────────────
  static const List<List<Color>> artworkGradients = [
    [Color(0xFF4A6FA5), Color(0xFF2D4A7A)], // Ocean blue
    [Color(0xFF7B6CF6), Color(0xFF4B3BA6)], // Violet
    [Color(0xFF5B9E8A), Color(0xFF2D6B58)], // Jade
    [Color(0xFF9B88C8), Color(0xFF6B5898)], // Lavender
    [Color(0xFF7BA8C9), Color(0xFF4A7A96)], // Sky
    [Color(0xFF7A9E79), Color(0xFF4A6D49)], // Sage
    [Color(0xFFC998B8), Color(0xFF995580)], // Rose
    [Color(0xFF9AC498), Color(0xFF5A9060)], // Mint
    [Color(0xFF5A98BA), Color(0xFF2D6B80)], // Teal
    [Color(0xFFBA9B5A), Color(0xFF806540)], // Gold
  ];

  static List<Color> gradientForIndex(int index) =>
      artworkGradients[index % artworkGradients.length];
}
