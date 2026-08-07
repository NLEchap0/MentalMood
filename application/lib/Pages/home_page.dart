import 'dart:async';
import 'dart:math';
import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/animations.dart';
import 'package:application/Utils/theme.dart';
import 'package:application/Widgets/glass_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<LoginController>().currentUser;
      if (user != null) context.read<MoodController>().fetchMoodHistory(user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final user = context.watch<LoginController>().currentUser;
    final theme = Theme.of(context);
    final status = moodController.getTodayStatus();
    final chartData = moodController.getChartData();
    final streak = moodController.getStreak();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async { if (user != null) await moodController.fetchMoodHistory(user.id); },
        color: AppTheme.accent,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('EEEE, dd/MM/yyyy').format(DateTime.now()).toUpperCase(), style: theme.textTheme.labelSmall),
                        const Text("Overview", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                    _buildTopPill(Icons.local_fire_department_rounded, "/streak", "$streak"),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    FadeInSlide(
                      child: GlassCard(
                        padding: const EdgeInsets.all(28),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: (status['color'] as Color).withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: Icon(status['icon'] as IconData, size: 36, color: status['color'] as Color),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("CURRENT VIBRATION", style: theme.textTheme.labelSmall),
                                  Text(status['label'], style: TextStyle(color: status['color'], fontSize: 26, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pushNamed(context, "/achievements"),
                              tooltip: "Achievements",
                              icon: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Neural Drift", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                        _RangeSelector(current: moodController.selectedRange, onChanged: moodController.setSelectedRange),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FadeInSlide(
                      delay: 100,
                      child: GlassCard(
                        padding: const EdgeInsets.fromLTRB(0, 32, 24, 12),
                        height: 300,
                        child: chartData.isEmpty 
                          ? const Center(child: Text("Synchronizing system data...", style: TextStyle(color: Colors.white24))) 
                          : _LineChartWidget(data: chartData, range: moodController.selectedRange),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildSectionHeader("Today's Neural Metrics"),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildMetricMiniCard(context, "Today's Avg", moodController.getTodayAverage()?.toStringAsFixed(1) ?? "--", Icons.analytics_rounded, AppTheme.accent),
                        const SizedBox(width: 12),
                        _buildMetricMiniCard(context, "Today's Logs", "${moodController.moodHistory.where((e) => DateFormat('yyyy-MM-dd').format(e.createdAt) == DateFormat('yyyy-MM-dd').format(DateTime.now())).length}", Icons.hub_rounded, AppTheme.sagePrimary),
                        const SizedBox(width: 12),
                        _buildMetricMiniCard(context, "History Peak", moodController.moodHistory.isEmpty ? "--" : "${moodController.moodHistory.map((e) => e.value).reduce(max)}", Icons.shutter_speed_rounded, Colors.amber),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildSectionHeader("System Insight"),
                    const SizedBox(height: 16),
                    FadeInSlide(
                      delay: 200,
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [const Icon(Icons.psychology_rounded, color: AppTheme.accent, size: 20), const SizedBox(width: 12), Text("NEURAL ANALYSIS", style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.accent))]),
                            const SizedBox(height: 16),
                            Text(moodController.getMoodSummary(), style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildSectionHeader("Recent Activity"),
                    const SizedBox(height: 16),
                    if (moodController.moodHistory.isEmpty)
                      const Center(child: Text("Zero activity recorded.", style: TextStyle(color: Colors.white10)))
                    else
                      ...moodController.moodHistory.take(2).map((entry) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildRecentLogTile(context, entry))),
                    const SizedBox(height: 140), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)));

  Widget _buildMetricMiniCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, color: color.withValues(alpha: 0.6), size: 18),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 4),
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLogTile(BuildContext context, dynamic entry) {
    final color = AppTheme.getSmoothColor(entry.value.toDouble());
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(width: 8, height: 32, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('HH:mm').format(entry.createdAt), style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900)),
                Text(entry.note?.isNotEmpty == true ? entry.note! : "Neural check-in confirmed.", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Icon(AppIcons.getMoodIcon(entry.value), color: color, size: 20),
        ],
      ),
    );
  }

  Widget _buildTopPill(IconData icon, String route, String label) {
    return HoverEffect(
      onTap: () => Navigator.pushNamed(context, route),
      customBorder: const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32))),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        customShape: const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32))),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.orange),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  final MoodRange current;
  final Function(MoodRange) onChanged;
  const _RangeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MoodRange>(
      initialValue: current,
      onSelected: onChanged,
      shape: const ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
        child: Row(
          children: [
            Text(_label(current).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.white54, letterSpacing: 1)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Colors.white30),
          ],
        ),
      ),
      itemBuilder: (c) => [
        const PopupMenuItem(value: MoodRange.last24h, child: Text("24h Analysis")),
        const PopupMenuItem(value: MoodRange.last7d, child: Text("7d Overview")),
        const PopupMenuItem(value: MoodRange.last30d, child: Text("30d Report")),
      ],
    );
  }
  String _label(MoodRange r) => r == MoodRange.last24h ? "24h" : r == MoodRange.last7d ? "7d" : "30d";
}

class _LineChartWidget extends StatefulWidget {
  final List<ChartMoodPoint> data;
  final MoodRange range;
  const _LineChartWidget({required this.data, required this.range});
  @override
  State<_LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<_LineChartWidget> {
  int? _showingTooltipIndex;
  Timer? _tooltipTimer;

  void _handleTouch(LineTouchResponse? response) {
    if (response == null || response.lineBarSpots == null || response.lineBarSpots!.isEmpty) {
      _tooltipTimer?.cancel();
      setState(() => _showingTooltipIndex = null);
      return;
    }
    final index = response.lineBarSpots!.first.spotIndex;
    if (index != _showingTooltipIndex) {
      _tooltipTimer?.cancel();
      _tooltipTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _showingTooltipIndex = index);
      });
    }
  }

  @override
  void dispose() { _tooltipTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final range = widget.range;
    final maxYData = data.map((e) => e.value).reduce(max);
    final fullColors = List.generate(12, (i) => AppTheme.getSmoothColor(i.toDouble()));
    
    return LineChart(
      LineChartData(
        minY: 0, maxY: 11,
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(y: 5.5, color: Colors.white.withValues(alpha: 0.1), strokeWidth: 1, dashArray: [10, 5], label: HorizontalLineLabel(show: true, alignment: Alignment.topRight, padding: const EdgeInsets.only(right: 10, bottom: 2), style: const TextStyle(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 1), labelResolver: (_) => 'STABILITY')),
        ]),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 60, interval: 2, getTitlesWidget: (value, meta) {
            String label = '';
            if (value == 1) label = 'DORMANT'; else if (value == 3) label = 'PULSE'; else if (value == 5) label = 'STASIS'; else if (value == 7) label = 'ACTIVE'; else if (value == 9) label = 'VIBRANT';
            return SideTitleWidget(meta: meta, child: Text(label, textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 1)));
          })),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 1, getTitlesWidget: (value, meta) {
            final int index = value.toInt();
            if (index < 0 || index >= data.length) return const SizedBox.shrink();
            int step = (data.length / 3.5).ceil();
            if (step < 1) step = 1;
            if (index != 0 && index != data.length - 1 && (index % step != 0 || index > data.length - step * 0.8)) return const SizedBox.shrink();
            final date = data[index].date;
            String format = range == MoodRange.last24h ? 'HH:mm' : 'dd/MM/yyyy';
            return SideTitleWidget(meta: meta, space: 14, child: Text(DateFormat(format).format(date), style: const TextStyle(fontSize: 8, color: Colors.white24, fontWeight: FontWeight.w900)));
          })),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchCallback: (event, response) => _handleTouch(response),
          getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes.map((index) {
            if (index != _showingTooltipIndex) return TouchedSpotIndicatorData(FlLine(color: Colors.transparent), FlDotData(show: false));
            final spot = barData.spots[index];
            final color = AppTheme.getSmoothColor(spot.y);
            return TouchedSpotIndicatorData(FlLine(color: color.withValues(alpha: 0.3), strokeWidth: 2, dashArray: [4, 4]), FlDotData(getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: Colors.white, strokeWidth: 3, strokeColor: color)));
          }).toList(),
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => const Color(0xFF1E1E2E).withValues(alpha: 0.9),
            tooltipRoundedRadius: 12, showOnTopOfTheChartBoxArea: true, fitInsideHorizontally: true, fitInsideVertically: true,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              if (spot.spotIndex != _showingTooltipIndex) return null;
              final color = AppTheme.getSmoothColor(spot.y);
              final labels = ['Dormant', 'Trace', 'Pulse', 'Core', 'Stasis', 'Flow', 'Active', 'Radiant', 'Vibrant', 'Zenith'];
              return LineTooltipItem("${labels[(spot.y.round() - 1).clamp(0, 9)]}\n", TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1), children: [TextSpan(text: "Level ${spot.y.toStringAsFixed(1)}", style: TextStyle(color: color.withValues(alpha: 0.6), fontWeight: FontWeight.w700, fontSize: 10))]);
            }).toList(),
          ),
          handleBuiltInTouches: false,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
            isCurved: true, curveSmoothness: 0.3, barWidth: 4,
            shadow: Shadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
            gradient: LinearGradient(colors: fullColors, stops: List.generate(12, (i) { final minY = data.map((e) => e.value).reduce(min); double range = maxYData - minY; return range <= 0.1 ? i / 11.0 : ((i.toDouble() - minY) / range).clamp(0.0, 1.0); }), begin: Alignment.bottomCenter, end: Alignment.topCenter),
            dotData: FlDotData(show: data.length < 15, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.white, strokeWidth: 2.5, strokeColor: AppTheme.getSmoothColor(spot.y))),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: fullColors.map((c) => c.withValues(alpha: c == const Color(0xFF00D2FF) ? 0.08 : 0.25)).toList(), stops: List.generate(12, (i) => (i.toDouble() / max(maxYData, 1.0)).clamp(0.0, 1.0)), begin: Alignment.bottomCenter, end: Alignment.topCenter)),
          ),
        ],
      ),
    );
  }
}
