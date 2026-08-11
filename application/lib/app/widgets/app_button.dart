import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Standard action button with consistent sizing and feedback.
/// [variant]: primary (white), secondary (accent), danger (coral).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (variant) {
      AppButtonVariant.primary => (Colors.white, AppColors.backgroundBase),
      AppButtonVariant.secondary => (
        AppColors.accent.withValues(alpha: 0.16),
        AppColors.accent,
      ),
      AppButtonVariant.accent => (AppColors.accent, AppColors.backgroundBase),
      AppButtonVariant.danger => (AppColors.danger, Colors.white),
    };

    final content = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color:
                  variant == AppButtonVariant.primary ||
                      variant == AppButtonVariant.accent
                  ? AppColors.backgroundBase
                  : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppTokens.sm),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: fg,
                ),
              ),
            ],
          );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
        disabledForegroundColor: AppColors.textFaint,
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.xl,
          vertical: AppTokens.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
        elevation: 0,
      ),
      child: content,
    );

    if (!isFullWidth) return button;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: SizedBox(width: double.infinity, child: button),
    );
  }
}

enum AppButtonVariant { primary, secondary, accent, danger }
