import 'package:application/domain/mood_labels.dart';
import 'package:application/domain/models.dart';
import 'package:intl/intl.dart';

/// Pure analytics over [MoodEntry] lists. No Flutter, no Drift.
class MoodAnalytics {
  const MoodAnalytics();

  double? todayAverage(List<MoodEntry> entries, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final todayStart = DateTime(reference.year, reference.month, reference.day);
    final todayEntries = entries
        .where((e) => e.createdAt.isAfter(todayStart))
        .toList();
    if (todayEntries.isEmpty) return null;
    final total = todayEntries.fold<int>(0, (sum, e) => sum + e.value);
    return total / todayEntries.length;
  }

  String todayStatusLabel(List<MoodEntry> entries, {DateTime? now}) {
    final avg = todayAverage(entries, now: now);
    if (avg == null) return 'Inactive';
    return moodLabelFor(avg.round());
  }

  List<ChartPoint> chartData(
    List<MoodEntry> entries,
    MoodRange range, {
    DateTime? now,
  }) {
    if (entries.isEmpty) return [];

    final reference = now ?? DateTime.now();
    final todayStart = DateTime(reference.year, reference.month, reference.day);
    final DateTime cutoff = switch (range) {
      MoodRange.last24h => reference.subtract(const Duration(hours: 24)),
      MoodRange.last7d => todayStart.subtract(const Duration(days: 6)),
      MoodRange.last30d => todayStart.subtract(const Duration(days: 29)),
    };

    final filtered = entries.where((e) => e.createdAt.isAfter(cutoff)).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (range == MoodRange.last24h) {
      return filtered
          .map((e) => ChartPoint(date: e.createdAt, value: e.value.toDouble()))
          .toList();
    }

    final groupByMonth = range == MoodRange.last30d && _spansMonths(filtered);
    return _groupBy(filtered, groupByMonth ? 'yyyy-MM' : 'yyyy-MM-dd');
  }

  List<ChartPoint> _groupBy(List<MoodEntry> filtered, String keyFormat) {
    final Map<String, List<double>> groups = {};
    for (final e in filtered) {
      final key = DateFormat(keyFormat).format(e.createdAt);
      groups.putIfAbsent(key, () => []).add(e.value.toDouble());
    }
    return groups.entries.map((entry) {
      final values = entry.value;
      final sum = values.fold<double>(0, (a, b) => a + b);
      final date = keyFormat == 'yyyy-MM'
          ? DateTime.parse('${entry.key}-01')
          : DateTime.parse(entry.key);
      return ChartPoint(date: date, value: sum / values.length);
    }).toList();
  }

  bool _spansMonths(List<MoodEntry> filtered) {
    if (filtered.isEmpty) return false;
    final months = filtered
        .map((e) => '${e.createdAt.year}-${e.createdAt.month}')
        .toSet();
    return months.length > 2;
  }

  int streak(List<MoodEntry> entries, {DateTime? now}) {
    if (entries.isEmpty) return 0;
    final daysRecorded = entries
        .map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt))
        .toSet();
    final reference = now ?? DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(reference);
    final yesterday = DateFormat(
      'yyyy-MM-dd',
    ).format(reference.subtract(const Duration(days: 1)));

    if (!daysRecorded.contains(today) && !daysRecorded.contains(yesterday)) {
      return 0;
    }
    int count = 0;
    DateTime checkDate = daysRecorded.contains(today)
        ? reference
        : reference.subtract(const Duration(days: 1));
    while (daysRecorded.contains(DateFormat('yyyy-MM-dd').format(checkDate))) {
      count++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return count;
  }

  int longestStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;
    final sortedDays =
        entries
            .map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt))
            .toSet()
            .toList()
          ..sort();
    if (sortedDays.isEmpty) return 0;

    int longest = 0, current = 0;
    DateTime? lastDate;
    for (final day in sortedDays) {
      final date = DateTime.parse(day);
      if (lastDate == null || date.difference(lastDate).inDays == 1) {
        current++;
      } else {
        if (current > longest) longest = current;
        current = 1;
      }
      lastDate = date;
    }
    return current > longest ? current : longest;
  }

  int activeDays(List<MoodEntry> entries) => entries
      .map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt))
      .toSet()
      .length;

  // --- WEEKLY STATS ---

  /// Entries within the last 7 calendar days ending today
  /// ([weeksBack] weeks before that window).
  List<MoodEntry> entriesInWeek(
    List<MoodEntry> entries, {
    DateTime? now,
    int weeksBack = 0,
  }) {
    final reference = now ?? DateTime.now();
    final todayStart = DateTime(reference.year, reference.month, reference.day);
    final weekStart = todayStart.subtract(Duration(days: 7 * weeksBack + 6));
    final weekEnd = todayStart.subtract(Duration(days: 7 * weeksBack - 1));
    return entries.where((e) {
      final at = e.createdAt;
      return !at.isBefore(weekStart) && at.isBefore(weekEnd);
    }).toList();
  }

  double? weekAverage(
    List<MoodEntry> entries, {
    DateTime? now,
    int weeksBack = 0,
  }) {
    final week = entriesInWeek(entries, now: now, weeksBack: weeksBack);
    if (week.isEmpty) return null;
    final total = week.fold<int>(0, (sum, e) => sum + e.value);
    return total / week.length;
  }

  int weekCount(List<MoodEntry> entries, {DateTime? now, int weeksBack = 0}) =>
      entriesInWeek(entries, now: now, weeksBack: weeksBack).length;

  int? weekPeak(List<MoodEntry> entries, {DateTime? now, int weeksBack = 0}) {
    final week = entriesInWeek(entries, now: now, weeksBack: weeksBack);
    if (week.isEmpty) return null;
    return week.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }

  /// Percentage change from [previous] to [current];
  /// null when either value is missing or not comparable (previous is zero).
  static double? percentChange(double? current, double? previous) {
    if (current == null || previous == null || previous == 0) return null;
    return ((current - previous) / previous) * 100;
  }
}
