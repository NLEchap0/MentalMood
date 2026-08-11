import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:flutter/material.dart';

/// Compact stat card: icon, value, optional trend vs previous period, label.
class MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  /// Trend label (e.g. "+12%", "+2"). Null hides the comparison.
  final String? trend;
  final bool trendUp;

  const MetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.trend,
    this.trendUp = true,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = trend == null
        ? AppColors.textFaint
        : trendUp
        ? AppColors.success
        : AppColors.danger;

    return Expanded(
      child: GlassCard(
        size: GlassCardSize.sm,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trend == null)
                  const Text(
                    '—',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textFaint,
                    ),
                  )
                else ...[
                  Icon(
                    trendUp
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 12,
                    color: trendColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    trend!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: trendColor,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.textFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
