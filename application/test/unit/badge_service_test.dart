import 'package:application/domain/models.dart';
import 'package:application/domain/services/badge_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const badgeService = BadgeService();

  MoodEntry entry(
    int id,
    int value,
    DateTime createdAt, {
    String? note,
    List<String> tags = const [],
  }) => MoodEntry(
    id: id,
    value: value,
    userId: 1,
    createdAt: createdAt,
    note: note,
    tags: tags,
  );

  List<MoodEntry> consecutiveDays(int days, DateTime end) => [
    for (var i = 0; i < days; i++)
      entry(i + 1, 6, end.subtract(Duration(days: i))),
  ];

  List<String> codesOf(List<BadgeDraft> drafts) =>
      drafts.map((d) => d.code).toList();

  group('BadgeService', () {
    test('no badges for empty history', () {
      expect(badgeService.evaluate(const [], unlockedCodes: {}), isEmpty);
    });

    test('streak badges unlock progressively', () {
      final now = DateTime(2026, 8, 10, 12);
      final drafts = badgeService.evaluate(
        consecutiveDays(8, now),
        unlockedCodes: {},
        now: now,
      );
      expect(codesOf(drafts), contains('streak_3'));
      expect(codesOf(drafts), contains('streak_7'));
      expect(codesOf(drafts), isNot(contains('streak_30')));
    });

    test('already unlocked badges are not duplicated', () {
      final now = DateTime(2026, 8, 10, 12);
      final drafts = badgeService.evaluate(
        consecutiveDays(8, now),
        unlockedCodes: {'streak_3', 'streak_7'},
        now: now,
      );
      expect(codesOf(drafts), isNot(contains('streak_3')));
      expect(codesOf(drafts), isNot(contains('streak_7')));
    });

    test('zen master unlocks at 14 day streak', () {
      final now = DateTime(2026, 8, 10, 12);
      final drafts = badgeService.evaluate(
        consecutiveDays(14, now),
        unlockedCodes: {},
        now: now,
      );
      expect(codesOf(drafts), contains('special_zen'));
    });

    test('total_50 unlocks at 50 entries', () {
      final now = DateTime(2026, 8, 10, 12);
      final history = [
        for (var i = 0; i < 50; i++)
          entry(i + 1, 5, now.subtract(Duration(hours: i * 3))),
      ];
      final drafts = badgeService.evaluate(
        history,
        unlockedCodes: {},
        now: now,
      );
      expect(codesOf(drafts), contains('total_50'));
    });

    test('notes_5 unlocks with notes on 5 entries', () {
      final now = DateTime(2026, 8, 10, 12);
      final history = [
        for (var i = 0; i < 5; i++)
          entry(i + 1, 5, now.subtract(Duration(days: i)), note: 'note $i'),
      ];
      final drafts = badgeService.evaluate(
        history,
        unlockedCodes: {},
        now: now,
      );
      expect(codesOf(drafts), contains('notes_5'));
    });

    test('early bird and night owl unlock by time of day', () {
      final now = DateTime(2026, 8, 10, 12);
      final history = [
        entry(1, 5, DateTime(2026, 8, 10, 7)), // morning
        entry(2, 5, DateTime(2026, 8, 9, 2)), // night
      ];
      final drafts = badgeService.evaluate(
        history,
        unlockedCodes: {},
        now: now,
      );
      expect(codesOf(drafts), contains('special_early'));
      expect(codesOf(drafts), contains('special_night'));
    });

    test('roller unlocks with both highs and lows', () {
      final now = DateTime(2026, 8, 10, 12);
      final history = [
        entry(1, 9, now.subtract(const Duration(days: 2))),
        entry(2, 2, now.subtract(const Duration(days: 1))),
      ];
      final drafts = badgeService.evaluate(
        history,
        unlockedCodes: {},
        now: now,
      );
      expect(codesOf(drafts), contains('special_roller'));
    });

    test('roller does not unlock without extremes', () {
      final now = DateTime(2026, 8, 10, 12);
      final history = [
        entry(1, 5, now.subtract(const Duration(days: 1))),
        entry(2, 6, now),
      ];
      final drafts = badgeService.evaluate(
        history,
        unlockedCodes: {},
        now: now,
      );
      expect(codesOf(drafts), isNot(contains('special_roller')));
    });

    test('social unlocks when logged with Friends or Family tag', () {
      final now = DateTime(2026, 8, 10, 12);
      final history = [
        entry(1, 7, now, tags: const ['Friends']),
      ];
      final drafts = badgeService.evaluate(
        history,
        unlockedCodes: {},
        now: now,
      );
      expect(codesOf(drafts), contains('special_social'));
    });
  });
}
