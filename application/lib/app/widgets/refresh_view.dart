import 'package:application/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Standard pull-to-refresh wrapper used by every scrollable page.
class RefreshView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const RefreshView({super.key, required this.onRefresh, required this.child});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      displacement: 60,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
