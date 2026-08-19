import 'package:application/app/theme/app_colors.dart';
import 'package:application/app/theme/app_icons.dart';
import 'package:application/app/widgets/app_background.dart';
import 'package:application/app/widgets/empty_state.dart';
import 'package:application/app/widgets/entrance_stagger.dart';
import 'package:application/app/widgets/glass_card.dart';
import 'package:application/app/widgets/refresh_view.dart';
import 'package:application/app/widgets/section_header.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/mood_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  /// Reloads the history and unlocked badges on pull-to-refresh.
  Future<void> _refresh(BuildContext context) async {
    final user = context.read<AuthController>().currentUser;
    if (user != null) {
      await context.read<MoodController>().fetchMoodHistory(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final unlocked = moodController.unlockedBadges;
    final unlockedCodes = unlocked.map((b) => b.code).toSet();

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(title: const Text('Achievements')),
      body: AppBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: RefreshView(
              onRefresh: () => _refresh(context),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
                child: EntranceStagger(
                  spacing: 24,
                  children: [
                    _buildCategory(context, 'Journaling Milestones', const [
                      ('streak_3', 'Rising Star', 'bolt', '3 day streak'),
                      ('streak_7', 'Full Week', 'bolt', '7 day streak'),
                      ('streak_30', 'Commitment', 'diamond', '30 day streak'),
                      ('total_50', 'Mood Master', 'school', '50 check-ins'),
                    ], unlockedCodes),
                    const SizedBox(height: 24),
                    _buildCategory(context, 'Special Moments', const [
                      (
                        'special_early',
                        'Early Bird',
                        'morning',
                        'Morning check-in',
                      ),
                      (
                        'special_night',
                        'Night Owl',
                        'night',
                        'Late night check-in',
                      ),
                      (
                        'special_zen',
                        'Zen Master',
                        'zen',
                        '14 day consistency',
                      ),
                      ('special_roller', 'Human', 'roller', 'Highs & lows'),
                      (
                        'special_social',
                        'Connection',
                        'social',
                        'Social butterfly',
                      ),
                      ('notes_5', 'Journalist', 'edit', 'Notes on 5 entries'),
                    ], unlockedCodes),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(
    BuildContext context,
    String title,
    List<(String, String, String, String)> badges,
    Set<String> unlockedCodes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 20),
        if (badges.isEmpty)
          const EmptyState(
            icon: Icons.emoji_events_outlined,
            title: 'No badges yet',
            message: 'Keep checking in to unlock your first badge.',
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final (code, name, icon, desc) = badges[index];
              final isUnlocked = unlockedCodes.contains(code);
              return _AchievementCard(
                title: name,
                icon: icon,
                description: desc,
                isUnlocked: isUnlocked,
              );
            },
          ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String icon;
  final String description;
  final bool isUnlocked;

  const _AchievementCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      size: GlassCardSize.sm,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.accent.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Opacity(
              opacity: isUnlocked ? 1.0 : 0.25,
              child: Icon(
                AppIcons.fromString(icon),
                size: 38,
                color: isUnlocked ? AppColors.accent : Colors.white54,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isUnlocked
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? AppColors.textSecondary : AppColors.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}
