import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/animations.dart';
import 'package:application/Utils/theme.dart';
import 'package:application/Widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StreakStatsPage extends StatelessWidget {
  const StreakStatsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final streak = moodController.getStreak();
    final longestStreak = moodController.getLongestStreak();
    final history = moodController.moodHistory;
    final totalDays = history.map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt)).toSet().length;
    return Scaffold(
      backgroundColor: Colors.transparent, appBar: AppBar(title: const Text("Consistency")),
      body: Container(decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient), child: SingleChildScrollView(padding: const EdgeInsets.all(24), physics: const BouncingScrollPhysics(), child: Column(children: [
        FadeInSlide(duration: 800, child: GlassCard(padding: const EdgeInsets.symmetric(vertical: 48), child: Column(children: [const Icon(Icons.local_fire_department_rounded, size: 72, color: Colors.orange), TweenAnimationBuilder<int>(duration: const Duration(milliseconds: 1500), tween: IntTween(begin: 0, end: streak), builder: (context, value, child) => Text("$value", style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: Colors.white))), const Text("DAY STREAK", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.white54))]))),
        const SizedBox(height: 32),
        Row(children: [_MetricPill(label: "Best", value: "$longestStreak", icon: Icons.emoji_events_rounded, color: Colors.amber), const SizedBox(width: 16), _MetricPill(label: "Active", value: "$totalDays", icon: Icons.calendar_today_rounded, color: Colors.blueAccent), const SizedBox(width: 16), _MetricPill(label: "Logs", value: "${history.length}", icon: Icons.edit_note_rounded, color: AppTheme.sagePrimary)]),
        const SizedBox(height: 48), _buildSectionLabel("Activity Heatmap"), const SizedBox(height: 16), _buildMonthlyHeatmap(history),
        const SizedBox(height: 48), _buildSectionLabel("Milestones"), const SizedBox(height: 16), _buildMilestones(streak),
        const SizedBox(height: 80),
      ]))),
    );
  }
  Widget _buildSectionLabel(String title) => Align(alignment: Alignment.centerLeft, child: Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 11, color: Colors.white38)));
  Widget _buildMonthlyHeatmap(List<dynamic> history) {
    final now = DateTime.now(); final daysInMonth = DateTime(now.year, now.month + 1, 0).day; final firstDayOfMonth = DateTime(now.year, now.month, 1); final startPadding = firstDayOfMonth.weekday - 1; final recordedDays = history.map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt)).toSet();
    return GlassCard(padding: const EdgeInsets.all(20), child: GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8), itemCount: daysInMonth + startPadding, itemBuilder: (context, index) { if (index < startPadding) return const SizedBox.shrink(); final day = index - startPadding + 1; final isRecorded = recordedDays.contains(DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, day))); return Container(decoration: BoxDecoration(color: isRecorded ? AppTheme.amberWarm : Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)), child: Center(child: Text("$day", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isRecorded ? Colors.white : Colors.white24)))); }));
  }
  Widget _buildMilestones(int streak) {
    final milestones = [7, 14, 30, 50, 100];
    return Column(children: milestones.map((m) { final progress = (streak / m).clamp(0.0, 1.0); return Padding(padding: const EdgeInsets.only(bottom: 12), child: GlassCard(padding: const EdgeInsets.all(20), child: Row(children: [Icon(streak >= m ? Icons.stars_rounded : Icons.lock_outline_rounded, color: streak >= m ? Colors.amber : Colors.white24, size: 28), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("$m Day Goal", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)), const SizedBox(height: 8), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: Colors.white10, color: streak >= m ? AppTheme.sagePrimary : Colors.amber.withValues(alpha: 0.5)))]))]))); }).toList());
  }
}

class _MetricPill extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _MetricPill({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: GlassCard(padding: const EdgeInsets.symmetric(vertical: 20), child: Column(children: [Icon(icon, color: color, size: 20), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)), Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white24))])));
  }
}
