import 'package:application/domain/models.dart';
import 'package:application/domain/services/mood_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const analytics = MoodAnalytics();

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

  group('MoodAnalytics Streaks', () {
    test('streak is 0 when history is empty', () {
      expect(analytics.streak(const []), 0);
    });

    test('streak counts consecutive days ending today', () {
      final now = DateTime(2026, 8, 10, 12);
      final history = [
        entry(1, 5, DateTime(2026, 8, 10, 9)),
        entry(2, 6, DateTime(2026, 8, 9, 20)),
        entry(3, 4, DateTime(2026, 8, 8, 18)),
        entry(4, 7, DateTime(2026, 8, 5, 10)), // gap breaks the streak
      ];
      expect(analytics.streak(history, now: now), 3);
    });

    test('streak is 0 when last record is older than yesterday', () {
      final now = DateTime(2026, 8, 10, 12);
      final history = [entry(1, 5, DateTime(2026, 8, 7, 10))];
      expect(analytics.streak(history, now: now), 0);
    });

    test('longestStreak ignores gaps in the middle', () {
      final history = [
        entry(1, 5, DateTime(2026, 8, 10)),
        entry(2, 5, DateTime(2026, 8, 9)),
        entry(3, 5, DateTime(2026, 8, 6)),
        entry(4, 5, DateTime(2026, 8, 5)),
        entry(5, 5, DateTime(2026, 8, 4)),
        entry(6, 5, DateTime(2026, 8, 2)),
      ];
      expect(analytics.longestStreak(history), 3);
    });
  });

  group('MoodAnalytics Averages', () {
    test('todayAverage ignores past entries', () {
      final now = DateTime(2026, 8, 10, 15);
      final history = [
        entry(1, 10, DateTime(2026, 8, 10, 9)),
        entry(2, 2, DateTime(2026, 8, 9, 20)),
      ];
      expect(analytics.todayAverage(history, now: now), 10.0);
    });

    test('todayAverage returns null with no entries today', () {
      expect(analytics.todayAverage(const []), null);
    });

    test('todayStatusLabel returns Inactive without data', () {
      expect(analytics.todayStatusLabel(const []), 'Inactive');
    });
  });

  group('MoodAnalytics Chart Data', () {
    test('empty history produces empty chart', () {
      expect(analytics.chartData(const [], MoodRange.last7d), isEmpty);
    });

    test('last24h keeps raw entries (no grouping)', () {
      final now = DateTime(2026, 8, 10, 12);
      final history = [
        entry(1, 6, DateTime(2026, 8, 10, 11)),
        entry(2, 8, DateTime(2026, 8, 10, 10)),
      ];
      final chart = analytics.chartData(history, MoodRange.last24h, now: now);
      expect(chart.length, 2);
      expect(chart[0].value, 8.0); // earliest first
      expect(chart[1].value, 6.0);
    });

    test('last7d groups by day (average per day)', () {
      final now = DateTime(2026, 8, 10, 12);
      final history = [
        entry(1, 4, DateTime(2026, 8, 10, 9)),
        entry(2, 8, DateTime(2026, 8, 10, 19)),
        entry(3, 6, DateTime(2026, 8, 9, 10)),
      ];
      final chart = analytics.chartData(history, MoodRange.last7d, now: now);
      expect(chart.length, 2);
      expect(chart.first.value, 6.0); // (4+8)/2
    });

    test('last7d excludes entries older than a week', () {
      final now = DateTime(2026, 8, 10, 12);
      final history = [
        entry(1, 5, DateTime(2026, 8, 3, 10)), // 7 days ago, outside window
        entry(2, 7, DateTime(2026, 8, 9, 10)),
      ];
      final chart = analytics.chartData(history, MoodRange.last7d, now: now);
      expect(chart.length, 1);
      expect(chart.single.value, 7.0);
    });

    test('last30d groups by day', () {
      final now = DateTime(2026, 8, 10, 12);
      final history = [
        entry(1, 5, DateTime(2026, 8, 1, 9)),
        entry(2, 9, DateTime(2026, 8, 1, 18)),
      ];
      final chart = analytics.chartData(history, MoodRange.last30d, now: now);
      expect(chart.length, 1);
      expect(chart.single.value, 7.0);
    });
  });

  group('MoodAnalytics Misc', () {
    test('activeDays counts unique days', () {
      final history = [
        entry(1, 5, DateTime(2026, 8, 10)),
        entry(2, 6, DateTime(2026, 8, 10, 18)),
        entry(3, 7, DateTime(2026, 8, 9)),
      ];
      expect(analytics.activeDays(history), 2);
    });
  });

  group('MoodAnalytics Weekly Stats', () {
    final now = DateTime(2026, 8, 10, 12); // Monday, 10 Aug 2026

    test('weekAverage only counts the last 7 calendar days', () {
      final history = [
        entry(1, 6, DateTime(2026, 8, 9, 10)), // within current week
        entry(2, 8, DateTime(2026, 8, 10, 9)), // within current week
        entry(3, 5, DateTime(2026, 8, 3, 12)), // previous week
      ];
      expect(analytics.weekAverage(history, now: now), 7.0);
    });

    test('weekAverage returns null when the week has no entries', () {
      expect(analytics.weekAverage(const [], now: now), null);
    });

    test('weekCount separates current and previous week', () {
      final history = [
        entry(1, 5, DateTime(2026, 8, 10, 9)), // current week
        entry(2, 6, DateTime(2026, 8, 5, 9)), // current week
        entry(3, 7, DateTime(2026, 8, 2, 9)), // previous week (Jul 28-Aug 3)
        entry(4, 8, DateTime(2026, 8, 3, 9)), // previous week
        entry(5, 4, DateTime(2026, 7, 25, 9)), // two weeks ago
      ];
      expect(analytics.weekCount(history, now: now), 2);
      expect(analytics.weekCount(history, now: now, weeksBack: 1), 2);
    });

    test('weekPeak returns the highest value of the week', () {
      final history = [
        entry(1, 6, DateTime(2026, 8, 9)),
        entry(2, 9, DateTime(2026, 8, 10)),
        entry(3, 10, DateTime(2026, 8, 3)), // previous week
      ];
      expect(analytics.weekPeak(history, now: now), 9);
      expect(analytics.weekPeak(history, now: now, weeksBack: 1), 10);
    });

    test('percentChange computes relative difference', () {
      expect(MoodAnalytics.percentChange(6, 4), 50.0);
      expect(MoodAnalytics.percentChange(3, 6), -50.0);
      expect(MoodAnalytics.percentChange(5, 5), 0.0);
    });

    test('percentChange is null when not comparable', () {
      expect(MoodAnalytics.percentChange(null, 4), null);
      expect(MoodAnalytics.percentChange(5, null), null);
      expect(MoodAnalytics.percentChange(5, 0), null);
    });
  });
}
