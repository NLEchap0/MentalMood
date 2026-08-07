import 'dart:ui';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Utils/animations.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final unlockedBadges = moodController.unlockedBadges;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Achievements")),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategory(context, "Journaling Milestones", [
                {'code': 'streak_7', 'title': 'Full Week', 'icon': 'bolt', 'desc': '7 day streak'},
                {'code': 'streak_30', 'title': 'Commitment', 'icon': 'diamond', 'desc': '30 day streak'},
                {'code': 'total_50', 'title': 'Mood Master', 'icon': 'school', 'desc': '50 logs'},
              ], unlockedBadges),
              const SizedBox(height: 48),
              _buildCategory(context, "Special Moments", [
                {'code': 'special_early', 'title': 'Early Bird', 'icon': 'morning', 'desc': 'Morning log'},
                {'code': 'special_night', 'title': 'Night Owl', 'icon': 'night', 'desc': 'Late night log'},
                {'code': 'special_zen', 'title': 'Zen Master', 'icon': 'zen', 'desc': 'Consistency'},
                {'code': 'special_roller', 'title': 'Human', 'icon': 'roller', 'desc': 'Highs & Lows'},
                {'code': 'special_social', 'title': 'Connection', 'icon': 'social', 'desc': 'Social butterfly'},
                {'code': 'notes_5', 'title': 'Journalist', 'icon': 'edit', 'desc': 'Detailed notes'},
              ], unlockedBadges),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, List<Map<String, String>> badges, List<dynamic> unlocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white38, letterSpacing: 2, fontSize: 11)),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.9),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final isUnlocked = unlocked.any((b) => b.code == badge['code']);
            return FadeInSlide(
              delay: index * 40,
              child: _AchievementCard(badge: badge, isUnlocked: isUnlocked),
            );
          },
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Map<String, String> badge;
  final bool isUnlocked;
  const _AchievementCard({required this.badge, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? AppTheme.accent.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Opacity(
              opacity: isUnlocked ? 1.0 : 0.2,
              child: Icon(AppIcons.fromString(badge['icon']!), size: 40, color: isUnlocked ? AppTheme.accent : Colors.white24),
            ),
          ),
          const SizedBox(height: 12),
          Text(badge['title']!, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isUnlocked ? Colors.white : Colors.white24), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(badge['desc']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isUnlocked ? Colors.white54 : Colors.white10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(56)),
          side: BorderSide(color: Colors.white10),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: child,
        ),
      ),
    );
  }
}
