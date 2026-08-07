import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color backgroundBase = Color(0xFF0F0C29);
  static const Color primary = Colors.white;
  static const Color accent = Color(0xFF00D2FF);
  static const Color terracottaError = Color(0xFFFF4D4D);
  static const Color sagePrimary = Color(0xFF00FF88);
  static const Color amberWarm = Color(0xFFFFB347);

  static Color getSmoothColor(double value) {
    if (value <= 3.5) return terracottaError;
    if (value >= 7.5) return sagePrimary;
    if (value <= 5.5) {
      double t = (value - 3.5) / 2.0;
      return Color.lerp(terracottaError, accent, t.clamp(0.0, 1.0))!;
    } else {
      double t = (value - 5.5) / 2.0;
      return Color.lerp(accent, sagePrimary, t.clamp(0.0, 1.0))!;
    }
  }

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const OutlinedBorder g3CardShape = ContinuousRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(56)),
    side: BorderSide(color: Colors.white10, width: 1.2),
  );

  static const OutlinedBorder g3PillShape = ContinuousRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(80)),
  );

  static const OutlinedBorder g3ButtonShape = ContinuousRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(48)),
  );

  static const OutlinedBorder g3SmallShape = ContinuousRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(24)),
  );

  static ThemeData get theme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF302B63),
        brightness: Brightness.dark,
        primary: primary,
        secondary: accent,
        surface: const Color(0xFF1E1E2E),
        error: terracottaError,
      ),
      scaffoldBackgroundColor: backgroundBase,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white, letterSpacing: 1),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(seconds: 1),
        showDuration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: ShapeDecoration(
          color: const Color(0xFF1E1E2E).withValues(alpha: 0.95),
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Colors.white10),
          ),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          foregroundColor: WidgetStateProperty.all(backgroundBase),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 60)),
          elevation: WidgetStateProperty.all(0),
          mouseCursor: WidgetStateProperty.all<MouseCursor?>(SystemMouseCursors.click),
          shape: WidgetStateProperty.all<OutlinedBorder>(g3ButtonShape),
          textStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all<MouseCursor?>(SystemMouseCursors.click),
          shape: WidgetStateProperty.all<OutlinedBorder>(g3SmallShape),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all<MouseCursor?>(SystemMouseCursors.click),
          shape: WidgetStateProperty.all<OutlinedBorder>(const CircleBorder()),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) return Colors.white.withValues(alpha: 0.05);
            if (states.contains(WidgetState.pressed)) return Colors.white.withValues(alpha: 0.1);
            return null;
          }),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      popupMenuTheme: PopupMenuThemeData(
        mouseCursor: WidgetStateProperty.all<MouseCursor?>(SystemMouseCursors.click),
        shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
      ),
      sliderTheme: SliderThemeData(
        mouseCursor: WidgetStateProperty.all<MouseCursor?>(SystemMouseCursors.click),
        trackHeight: 2,
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white10,
        thumbColor: Colors.white,
        overlayColor: Colors.white10,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.white24)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        displayLarge: const TextStyle(fontWeight: FontWeight.w900, fontSize: 34, color: Colors.white, letterSpacing: -1),
        titleLarge: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white),
        bodyLarge: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
        bodyMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
        labelSmall: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 2),
      ),
    );
  }
}

class AppIcons {
  static IconData getMoodIcon(int value) {
    switch (value) {
      case 1: return Icons.radio_button_unchecked_rounded; 
      case 2: return Icons.blur_on_rounded;                  
      case 3: return Icons.trip_origin_rounded;       
      case 4: return Icons.adjust_rounded;                 
      case 5: return Icons.tonality_rounded;                  
      case 6: return Icons.motion_photos_on_rounded;                
      case 7: return Icons.track_changes_rounded;         
      case 8: return Icons.brightness_high_rounded;             
      case 9: return Icons.flare_rounded;           
      case 10: return Icons.auto_awesome_rounded;         
      default: return Icons.lens_blur_rounded;
    }
  }

  static IconData fromString(String name) {
    switch (name) {
      case 'work': return Icons.work_outline_rounded;
      case 'sport': return Icons.fitness_center_rounded;
      case 'food': return Icons.restaurant_rounded;
      case 'sleep': return Icons.bedtime_outlined;
      case 'family': return Icons.groups_2_rounded;
      case 'friends': return Icons.person_add_rounded;
      case 'hobby': return Icons.palette_outlined;
      case 'weather': return Icons.wb_sunny_outlined;
      case 'streak': return Icons.local_fire_department_rounded;
      case 'bolt': return Icons.bolt_rounded;
      case 'diamond': return Icons.diamond_rounded;
      case 'eco': return Icons.eco_rounded;
      case 'school': return Icons.school_rounded;
      case 'trophy': return Icons.emoji_events_rounded;
      case 'edit': return Icons.edit_note_rounded;
      case 'morning': return Icons.wb_twilight_rounded;
      case 'night': return Icons.nightlight_round;
      case 'zen': return Icons.spa_rounded;
      case 'roller': return Icons.timeline_rounded;
      case 'social': return Icons.hub_rounded;
      default: return Icons.label_important_outline_rounded;
    }
  }
}
