import 'package:application/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Applies the shared gradient background. Used by every pushed page
/// AND the tab shell, so navigation never changes the look.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: child,
    );
  }
}
