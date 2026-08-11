import 'package:flutter/material.dart';

/// "Calm Tech" palette — deep violet-night base, lavender accent,
/// warm coral→sage mood scale. Single source of truth for colors.
abstract final class AppColors {
  // Background
  static const Color backgroundBase = Color(0xFF16121F);
  static const List<Color> backgroundGradient = [
    Color(0xFF1B1527),
    Color(0xFF221A33),
    Color(0xFF14101F),
  ];

  // Surfaces
  static const Color surface = Color(0xFF211B31);

  // Text
  static const Color textPrimary = Color(0xFFF5F2FF);
  static const Color textSecondary = Color(0xFFA9A0C0);
  static const Color textFaint = Color(0xFF6B6480);

  // Accents
  static const Color accent = Color(0xFF9B8CFF);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF6FCF97);
  static const Color gold = Color(0xFFFFC94D);

  // Mood scale (1..10): coral → peach → sage
  static const Color moodLow = Color(0xFFFF7A6E);
  static const Color moodMid = Color(0xFFFFB35C);
  static const Color moodHigh = Color(0xFF6FCF97);
}
