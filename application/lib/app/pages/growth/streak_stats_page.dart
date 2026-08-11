import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/widgets/app_background.dart';
import 'package:application/app/widgets/entrance_stagger.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:application/app/widgets/metric_card.dart';
import 'package:application/app/widgets/refresh_view.dart';
import 'package:application/app/widgets/section_header.dart';
import 'package:application/domain/models.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/mood_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StreakStatsPage extends StatelessWidget {
  const StreakStatsPage({super.key});

  /// Reloads the history that drives streaks and the heatmap.
  Future<void> _refresh(BuildContext context) async {
    final user = context.read<AuthController>().currentUser;
    if (user != null) {
      await context.read<MoodController>().fetchMoodHistory(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final history = moodController.moodHistory;
    final streak = moodController.getStreak();
    final longest = moodController.getLongestStreak();
    final activeDays = moodController.getActiveDays();

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(title: const Text('Consistency')),
      body: AppBackground(
        child: RefreshView(
          onRefresh: () => _refresh(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 80),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: EntranceStagger(
                  children: [
                    GlassCard(
                      size: GlassCardSize.lg,
                      padding: const EdgeInsets.symmetric(vertical: 44),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.gold,
                            size: 64,
                          ),
                          const SizedBox(height: 8),
                          TweenAnimationBuilder<int>(
                            duration: const Duration(milliseconds: 1500),
                            tween: IntTween(begin: 0, end: streak),
                            builder: (context, value, child) => Text(
                              '$value',
                              style: const TextStyle(
                                fontSize: 76,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Text(
                            'DAY STREAK',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        MetricCard(
                          icon: Icons.emoji_events_rounded,
                          value: '$longest',
                          label: 'Best',
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 12),
                        MetricCard(
                          icon: Icons.calendar_today_rounded,
                          value: '$activeDays',
                          label: 'Active days',
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 12),
                        MetricCard(
                          icon: Icons.edit_note_rounded,
                          value: '${history.length}',
                          label: 'Total logs',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const SectionHeader(title: 'Activity Heatmap'),
                    _buildMonthlyHeatmap(history),
                    const SectionHeader(title: 'Milestones'),
                    _buildMilestones(streak),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyHeatmap(List<MoodEntry> history) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final startPadding = firstDayOfMonth.weekday - 1;
    final recordedDays = history
        .map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt))
        .toSet();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: daysInMonth + startPadding,
        itemBuilder: (context, index) {
          if (index < startPadding) return const SizedBox.shrink();
          final day = index - startPadding + 1;
          final isRecorded = recordedDays.contains(
            DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, day)),
          );
          return Container(
            decoration: BoxDecoration(
              color: isRecorded
                  ? AppColors.gold.withValues(alpha: 0.75)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isRecorded ? Colors.white : AppColors.textFaint,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMilestones(int streak) {
    final milestones = [7, 14, 30, 50, 100];
    return Column(
      children: [
        for (final m in milestones)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              size: GlassCardSize.sm,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    streak >= m
                        ? Icons.stars_rounded
                        : Icons.lock_outline_rounded,
                    color: streak >= m ? AppColors.gold : AppColors.textFaint,
                    size: 26,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$m Day Goal',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (streak / m).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: Colors.white10,
                            color: streak >= m
                                ? AppColors.success
                                : AppColors.gold.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
