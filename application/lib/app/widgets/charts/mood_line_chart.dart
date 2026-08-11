import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/theme/app_theme.dart';
import 'package:application/domain/models.dart';
import 'package:application/domain/mood_labels.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Mood history line chart with a value-mapped color gradient.
class MoodLineChart extends StatelessWidget {
  final List<ChartPoint> data;
  final MoodRange range;

  const MoodLineChart({super.key, required this.data, required this.range});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxYData = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minY = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final maxY = (maxYData + 1.5).clamp(1.0, 12.0).toDouble();

    // Snap the bottom of the axis to an ODD integer so the fixed interval
    // always lands exactly on the mood labels (1, 3, 5, 7, 9) — like the
    // website chart. A fractional floor would shift every tick off-label.
    final rawMin = (minY - 1.5).clamp(1.0, 10.0).floor();
    final minYShow =
        (rawMin.isEven ? rawMin - 1 : rawMin).clamp(1, 10).toDouble();

    // Value-mapped gradient: the line color at any height equals the
    // mood color of that value (coral = low, sage = high).
    final scaleColors = [
      for (var v = 0; v <= 10; v++) AppTheme.getSmoothColor(v.toDouble()),
    ];
    final valueSpan = (maxY - minYShow).clamp(0.1, 12.0);
    final gradientStops = [
      for (var v = 0; v <= 10; v++)
        ((v - minYShow) / valueSpan).clamp(0.0, 1.0),
    ];

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              minY: minYShow,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withValues(alpha: 0.06),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      // Compact axis, like the website: only the middle
                      // zone labels (Pulse, Stasis, Active).
                      final label = switch (value.toInt()) {
                        3 => moodLabels[2],
                        5 => moodLabels[4],
                        7 => moodLabels[6],
                        _ => '',
                      };
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          label,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textFaint,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox.shrink();
                      }
                      var step = (data.length / 3.5).ceil();
                      if (step < 1) step = 1;
                      final isFirst = index == 0;
                      final isLast = index == data.length - 1;
                      if (!isFirst &&
                          !isLast &&
                          (index % step != 0 ||
                              index > data.length - step * 0.8)) {
                        return const SizedBox.shrink();
                      }
                      final format = range == MoodRange.last24h
                          ? 'HH:mm'
                          : 'dd/MM';
                      return SideTitleWidget(
                        meta: meta,
                        space: 14,
                        child: Text(
                          DateFormat(format).format(data[index].date),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textFaint,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surface,
                  tooltipRoundedRadius: 12,
                  getTooltipItems: (spots) => spots.map((spot) {
                    return LineTooltipItem(
                      '${moodLabels[(spot.y.round() - 1).clamp(0, 9)]} · '
                      '${spot.y.toStringAsFixed(1)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  // Low zone reference line
                  HorizontalLine(
                    y: 3.5,
                    color: Colors.white.withValues(alpha: 0.06),
                    strokeWidth: 1,
                    dashArray: [10, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 6, bottom: 2),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.textFaint,
                      ),
                      labelResolver: (_) => 'LOW',
                    ),
                  ),
                  // Stability reference line
                  HorizontalLine(
                    y: 5.5,
                    color: Colors.white.withValues(alpha: 0.1),
                    strokeWidth: 1,
                    dashArray: [10, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 10, bottom: 2),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.textFaint,
                      ),
                      labelResolver: (_) => 'STABILITY',
                    ),
                  ),
                  // High zone reference line
                  HorizontalLine(
                    y: 7.5,
                    color: Colors.white.withValues(alpha: 0.06),
                    strokeWidth: 1,
                    dashArray: [10, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 6, bottom: 2),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.textFaint,
                      ),
                      labelResolver: (_) => 'HIGH',
                    ),
                  ),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < data.length; i++)
                      FlSpot(i.toDouble(), data[i].value),
                  ],
                  isCurved: true,
                  curveSmoothness: 0.3,
                  barWidth: 3,
                  color: AppTheme.getSmoothColor(maxYData),
                  gradient: LinearGradient(
                    colors: scaleColors,
                    stops: gradientStops,
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 3,
                          color: AppTheme.getSmoothColor(spot.y),
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.getSmoothColor(
                          maxYData,
                        ).withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Align the legend with the plot area (the left axis strip is 28px).
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 0, 0, 0),
          child: _MoodScaleLegend(),
        ),
      ],
    );
  }
}

/// Legend explaining the mood color scale (low → medium → high).
class _MoodScaleLegend extends StatelessWidget {
  const _MoodScaleLegend();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: const LinearGradient(
              colors: [
                AppColors.moodLow,
                AppColors.moodMid,
                AppColors.moodHigh,
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _LegendLabel(text: 'Low', color: AppColors.moodLow),
            _LegendLabel(text: 'Medium', color: AppColors.moodMid),
            _LegendLabel(text: 'High', color: AppColors.moodHigh),
          ],
        ),
      ],
    );
  }
}

class _LegendLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _LegendLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
