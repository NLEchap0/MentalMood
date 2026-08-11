import 'package:application/domain/models.dart';
import 'package:application/domain/services/mood_analytics.dart';

/// A badge that should be created in storage.
class BadgeDraft {
  final String code;
  final String title;
  final String description;
  final String icon;

  const BadgeDraft({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Pure badge unlock rules. Decides WHICH badges qualify;
/// storage side effects are left to the controller.
class BadgeService {
  const BadgeService();

  List<BadgeDraft> evaluate(
    List<MoodEntry> history, {
    required Set<String> unlockedCodes,
    DateTime? now,
  }) {
    if (history.isEmpty) return [];
    final drafts = <BadgeDraft>[];
    final analytics = MoodAnalytics();
    final streak = analytics.streak(history, now: now);

    void add(String code, String title, String desc, String icon) {
      if (!unlockedCodes.contains(code)) {
        drafts.add(
          BadgeDraft(code: code, title: title, description: desc, icon: icon),
        );
      }
    }

    if (streak >= 3) {
      add('streak_3', 'Rising Star', '3 day mood streak!', 'bolt');
    }
    if (streak >= 7) {
      add('streak_7', 'Week Warrior', '7 day mood streak!', 'bolt');
    }
    if (streak >= 14) {
      add('special_zen', 'Zen Master', '14 day consistency', 'zen');
    }
    if (streak >= 30) {
      add('streak_30', 'Dedicated', '30 day mood streak!', 'diamond');
    }
    if (history.length >= 50) {
      add('total_50', 'Mood Master', 'Logged 50 moods!', 'school');
    }

    final noteCount = history.where((e) => e.hasNote).length;
    if (noteCount >= 5) {
      add('notes_5', 'Journalist', 'Added notes to 5 entries', 'edit');
    }

    if (history.any((e) => e.createdAt.hour >= 5 && e.createdAt.hour <= 8)) {
      add('special_early', 'Early Bird', 'Morning check-in', 'morning');
    }
    if (history.any((e) => e.createdAt.hour >= 0 && e.createdAt.hour <= 4)) {
      add('special_night', 'Night Owl', 'Late night log', 'night');
    }

    final values = history.map((e) => e.value);
    if (values.any((v) => v >= 8) && values.any((v) => v <= 3)) {
      add('special_roller', 'Human', 'Highs & Lows', 'roller');
    }

    const socialTags = ['Friends', 'Family'];
    if (history.any((e) => e.tags.any(socialTags.contains))) {
      add('special_social', 'Connection', 'Social butterfly', 'social');
    }

    return drafts;
  }
}
