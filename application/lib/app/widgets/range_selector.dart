import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/theme/app_tokens.dart';
import 'package:application/domain/models.dart';
import 'package:flutter/material.dart';

/// Segmented control for the chart time range.
class RangeSelector extends StatelessWidget {
  final MoodRange selected;
  final ValueChanged<MoodRange> onChanged;

  const RangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const List<(MoodRange, String)> _options = [
    (MoodRange.last24h, '24H'),
    (MoodRange.last7d, '7D'),
    (MoodRange.last30d, '30D'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (range, label) in _options)
            Padding(
              padding: const EdgeInsets.all(2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: range == selected
                      ? AppColors.accent.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
                child: InkWell(
                  onTap: () => onChanged(range),
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: range == selected
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
