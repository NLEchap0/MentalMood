import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/theme/app_tokens.dart';
import 'package:application/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Central theme factory. All global widget styling lives here.
abstract final class AppTheme {
  static Color getSmoothColor(double value) {
    final t = ((value.clamp(1.0, 10.0) - 1.0) / 9.0).clamp(0.0, 1.0);
    if (t < 0.5) {
      return Color.lerp(AppColors.moodLow, AppColors.moodMid, t * 2)!;
    }
    return Color.lerp(AppColors.moodMid, AppColors.moodHigh, (t - 0.5) * 2)!;
  }

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: AppColors.backgroundGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get theme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
        primary: AppColors.accent,
        secondary: AppColors.success,
        error: AppColors.danger,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.backgroundBase,
      textTheme: AppTypography.textTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: AppColors.textPrimary,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          foregroundColor: WidgetStateProperty.all(AppColors.backgroundBase),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: AppTokens.xl,
              vertical: AppTokens.lg,
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          mouseCursor: WidgetStateProperty.all<MouseCursor?>(
            SystemMouseCursors.click,
          ),
          shape: WidgetStateProperty.all<OutlinedBorder>(_pillShape),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all<MouseCursor?>(
            SystemMouseCursors.click,
          ),
          foregroundColor: WidgetStateProperty.all(AppColors.textSecondary),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          shape: WidgetStateProperty.all<OutlinedBorder>(_pillShape),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all<MouseCursor?>(
            SystemMouseCursors.click,
          ),
          shape: WidgetStateProperty.all<OutlinedBorder>(const CircleBorder()),
          minimumSize: WidgetStateProperty.all(
            const Size.square(AppTokens.touchTarget),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.06);
            }
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.12);
            }
            return null;
          }),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.28)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.xl,
          vertical: 18,
        ),
      ),

      sliderTheme: SliderThemeData(
        mouseCursor: WidgetStateProperty.all<MouseCursor?>(
          SystemMouseCursors.click,
        ),
        trackHeight: 3,
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
        thumbColor: Colors.white,
        overlayColor: AppColors.accent.withValues(alpha: 0.15),
        valueIndicatorColor: AppColors.accent,
        valueIndicatorTextStyle: const TextStyle(
          color: AppColors.backgroundBase,
          fontWeight: FontWeight.w800,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.04),
        selectedColor: AppColors.accent.withValues(alpha: 0.18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        checkmarkColor: AppColors.accent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusMd)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        mouseCursor: WidgetStateProperty.all<MouseCursor?>(
          SystemMouseCursors.click,
        ),
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        textStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),

      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(seconds: 1),
        showDuration: const Duration(milliseconds: 600),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: ShapeDecoration(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        textStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
      ),
    );
  }

  static const OutlinedBorder _pillShape = ContinuousRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppTokens.radiusPill)),
  );
}
