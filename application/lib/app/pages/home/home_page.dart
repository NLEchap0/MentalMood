import 'package:application/app/navigation/app_navigator.dart';
import 'package:application/app/pages/growth/achievements_page.dart';
import 'package:application/app/pages/growth/streak_stats_page.dart';
import 'package:application/app/pages/journal/add_mood_page.dart';
import 'package:application/app/pages/journal/mood_detail_page.dart';
import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/theme/app_icons.dart';
import 'package:application/app/theme/app_theme.dart';
import 'package:application/app/theme/animations.dart';
import 'package:application/app/widgets/app_background.dart';
import 'package:application/app/widgets/charts/mood_line_chart.dart';
import 'package:application/app/widgets/empty_state.dart';
import 'package:application/app/widgets/entrance_stagger.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:application/app/widgets/metric_card.dart';
import 'package:application/app/widgets/range_selector.dart';
import 'package:application/app/widgets/refresh_view.dart';
import 'package:application/app/widgets/section_header.dart';
import 'package:application/domain/models.dart';
import 'package:application/domain/mood_labels.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/mood_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Reloads mood history (chart, metrics, activity) on pull-to-refresh.
  Future<void> _refresh(BuildContext context) async {
    final user = context.read<AuthController>().currentUser;
    if (user != null) {
      await context.read<MoodController>().fetchMoodHistory(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final user = context.read<AuthController>().currentUser;
    final chartData = moodController.getChartData();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: RefreshView(
            onRefresh: () => _refresh(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 150),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: EntranceStagger(
                    spacing: 32,
                    children: [
                      _buildHeader(context, user),
                      _buildStatusCard(context, moodController),
                      _buildChartCard(context, moodController, chartData),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: SectionHeader(title: 'Weekly Stats'),
                      ),
                      _buildMetrics(context, moodController),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: SectionHeader(title: 'Recent Activity'),
                      ),
                      _buildRecentActivity(context, moodController),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppUser? user) {
    final now = DateTime.now();
    final name = user != null ? user.name : '';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, d MMMM').format(now).toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.textFaint,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Overview, $name',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        HoverEffect(
          onTap: () => AppNavigator.push(context, const AchievementsPage()),
          child: _HeaderIcon(
            icon: Icons.emoji_events_outlined,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(width: 12),
        HoverEffect(
          onTap: () => AppNavigator.push(context, const StreakStatsPage()),
          child: _StreakChip(
            streak: context.read<MoodController>().getStreak(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, MoodController controller) {
    final avg = controller.getTodayAverage();
    final status = controller.getTodayStatusLabel();
    final color = avg != null
        ? AppTheme.getSmoothColor(avg)
        : AppColors.textFaint;
    final icon = avg != null
        ? AppIcons.getMoodIcon(avg.round())
        : Icons.lens_blur_rounded;

    return GlassCard(
      size: GlassCardSize.md,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  avg != null
                      ? 'Average ${avg.toStringAsFixed(1)} / 10 today'
                      : 'No check-in yet today',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    MoodController controller,
    List<ChartPoint> data,
  ) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(4, 24, 32, 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'MOOD OVERVIEW',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Text(
                  'NEURAL DRIFT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textFaint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: EmptyState(
                icon: Icons.bubble_chart_outlined,
                title: controller.moodHistory.isEmpty
                    ? 'No data yet'
                    : 'Nothing in this range',
                message: controller.moodHistory.isEmpty
                    ? 'Log your first check-in to start your mood drift.'
                    : 'Try a wider time range to see your history.',
                actionLabel: 'Add Check-in',
                onAction: () => AppNavigator.push(context, const AddMoodPage()),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RangeSelector(
                selected: controller.selectedRange,
                onChanged: controller.setSelectedRange,
              ),
            ),
            MoodLineChart(data: data, range: controller.selectedRange),
          ],
        ],
      ),
    );
  }

  Widget _buildMetrics(BuildContext context, MoodController controller) {
    final avg = controller.getWeekAverage();
    final avgChange = controller.getWeekAverageChange();
    final count = controller.getWeekCount();
    final countChange = controller.getWeekCountChange();
    final peak = controller.getWeekPeak();
    final peakDelta = controller.getWeekPeakDelta();

    return Row(
      children: [
        MetricCard(
          icon: Icons.stacked_line_chart_rounded,
          value: avg?.toStringAsFixed(1) ?? '—',
          label: 'Average',
          color: AppColors.accent,
          trend: _formatPercent(avgChange),
          trendUp: (avgChange ?? 0) >= 0,
        ),
        const SizedBox(width: 12),
        MetricCard(
          icon: Icons.edit_note_rounded,
          value: '$count',
          label: 'Check-ins',
          color: AppColors.success,
          trend: _formatPercent(countChange),
          trendUp: (countChange ?? 0) >= 0,
        ),
        const SizedBox(width: 12),
        MetricCard(
          icon: Icons.trending_up_rounded,
          value: peak?.toString() ?? '—',
          label: 'Peak',
          color: AppColors.gold,
          trend: peakDelta == null
              ? null
              : peakDelta > 0
              ? '+$peakDelta'
              : '$peakDelta',
          trendUp: (peakDelta ?? 0) >= 0,
        ),
      ],
    );
  }

  static String _formatPercent(double? change) {
    if (change == null) return '—';
    final rounded = change.round();
    return rounded > 0 ? '+$rounded%' : '$rounded%';
  }

  Widget _buildRecentActivity(BuildContext context, MoodController controller) {
    final recent = controller.moodHistory.take(5).toList();
    if (recent.isEmpty) {
      return const GlassCard(
        size: GlassCardSize.sm,
        padding: EdgeInsets.all(20),
        child: Text(
          'No activity recorded yet. Your check-ins will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textFaint),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < recent.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == recent.length - 1 ? 0 : 12),
            child: _RecentEntryTile(entry: recent[i]),
          ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _HeaderIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _StreakChip extends StatelessWidget {
  final int streak;
  const _StreakChip({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.gold,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentEntryTile extends StatelessWidget {
  final MoodEntry entry;
  const _RecentEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getSmoothColor(entry.value.toDouble());
    return HoverEffect(
      onTap: () => AppNavigator.push(context, MoodDetailPage(entry: entry)),
      child: GlassCard(
        size: GlassCardSize.sm,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.getMoodIcon(entry.value),
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        moodLabelFor(entry.value).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat.Hm().format(entry.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textFaint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.hasNote
                        ? entry.note!
                        : 'Recorded a level ${entry.value} state.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: entry.hasNote
                          ? AppColors.textSecondary
                          : AppColors.textFaint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textFaint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
