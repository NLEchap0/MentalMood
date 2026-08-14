import 'package:flutter/material.dart';

/// Typography system: Geist (Vercel) for everything,
/// with tight tracking on display sizes and generous leading on body text.
abstract final class AppTypography {
  static const String displayFont = 'Geist';
  static const String bodyFont = 'Geist';

  static TextTheme get textTheme {
    final base = ThemeData(brightness: Brightness.dark).textTheme;

    return base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
            fontFamily: displayFont,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
          displayMedium: base.displayMedium?.copyWith(
            fontFamily: displayFont,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.75,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontFamily: displayFont,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontFamily: displayFont,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontFamily: bodyFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            fontFamily: bodyFont,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontFamily: bodyFont,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontFamily: bodyFont,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: base.labelMedium?.copyWith(
            fontFamily: bodyFont,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          labelSmall: base.labelSmall?.copyWith(
            fontFamily: bodyFont,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        )
        .apply(bodyColor: Colors.white, displayColor: Colors.white);
  }
}
