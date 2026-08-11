import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system: Outfit for display/numbers, Poppins for body.
abstract final class AppTypography {
  static TextTheme get textTheme {
    final base = ThemeData(brightness: Brightness.dark).textTheme;
    final outfit = GoogleFonts.outfitTextTheme(base);
    final poppins = GoogleFonts.poppinsTextTheme(base);

    return base
        .copyWith(
          displayLarge: outfit.displayLarge?.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          displayMedium: outfit.displayMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          headlineSmall: outfit.headlineSmall?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
          titleLarge: outfit.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: poppins.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: poppins.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          bodyMedium: poppins.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          labelLarge: poppins.labelLarge?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: poppins.labelMedium?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          labelSmall: poppins.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        )
        .apply(bodyColor: Colors.white, displayColor: Colors.white);
  }
}
