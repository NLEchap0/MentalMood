import 'package:flutter/material.dart';

/// Neon dark palette — near-black violet backgrounds with
/// luminous accent colors and a neon mood scale.
abstract final class AppColors {
  // Background (dark violet, gradient from the theme palette)
  static const Color backgroundBase = Color(0xFF100C1B);
  static const List<Color> backgroundGradient = [
    Color(0xFF181123),
    Color(0xFF141020),
    Color(0xFF0C0918),
  ];

  // Surfaces
  static const Color surface = Color(0xFF171221);

  // Text
  static const Color textPrimary = Color(0xFFF5F2FF);
  static const Color textSecondary = Color(0xFFA9A0C0);
  static const Color textFaint = Color(0xFF6B6480);

  // Accents (neon)
  static const Color accent = Color(0xFFB388FF);
  static const Color danger = Color(0xFFFF3B5C);
  static const Color success = Color(0xFF00FF9C);
  static const Color gold = Color(0xFFFFE14D);

  // Mood scale (1..10) — neon coral → amber → green
  static const Color moodLow = Color(0xFFFF5470);
  static const Color moodMid = Color(0xFFFFB020);
  static const Color moodHigh = Color(0xFF00FF9C);
}
