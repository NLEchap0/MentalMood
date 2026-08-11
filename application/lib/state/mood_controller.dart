import 'dart:math';

import 'package:application/data/repositories/emotion_repository.dart';
import 'package:application/domain/models.dart';
import 'package:application/domain/services/badge_service.dart';
import 'package:application/domain/services/mood_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Orchestrates data between the emotion repository and the UI.
class MoodController extends ChangeNotifier {
  final EmotionRepository emotionRepository;
  final MoodAnalytics _analytics = const MoodAnalytics();
  final BadgeService _badgeService = const BadgeService();

  MoodController({required this.emotionRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<MoodEntry> _moodHistory = [];
  List<MoodEntry> get moodHistory => _moodHistory;

  List<MoodTag> _availableTags = [];
  List<MoodTag> get availableTags => _availableTags;

  List<Badge> _unlockedBadges = [];
  List<Badge> get unlockedBadges => _unlockedBadges;

  MoodRange _selectedRange = MoodRange.last7d;
  MoodRange get selectedRange => _selectedRange;

  bool _manuallySelected = false;

  // --- RANGE SELECTION ---

  void setSelectedRange(MoodRange range) {
    _selectedRange = range;
    _manuallySelected = true;
    notifyListeners();
  }

  // --- ACTIONS ---

  Future<bool> saveMood({
    required int userId,
    required int value,
    String? note,
    List<String>? tags,
  }) async {
    _setLoading(true, clearError: true);
    try {
      await emotionRepository.addEmotion(
        userId: userId,
        value: value,
        note: note,
        tags: tags,
      );
      await fetchMoodHistory(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Neural sync failed. Connection unstable.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchMoodHistory(int userId) async {
    _setLoading(true);
    try {
      _moodHistory = await emotionRepository.getEmotionsForUser(userId);

      // Auto-fallback: promote to week view once a week has enough data.
      if (!_manuallySelected) {
        final now = DateTime.now();
        final weekCutoff = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        final uniqueDaysInWeek = _moodHistory
            .where((e) => e.createdAt.isAfter(weekCutoff))
            .map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt))
            .toSet()
            .length;
        _selectedRange = uniqueDaysInWeek >= 2
            ? MoodRange.last7d
            : MoodRange.last24h;
      }

      await fetchAvailableTags(userId);
      await _syncBadges(userId);
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'System logs inaccessible.';
      _setLoading(false);
    }
  }

  Future<void> fetchAvailableTags(int userId) async {
    try {
      _availableTags = await emotionRepository.getTagsForUser(userId);
    } catch (e) {
      debugPrint('Tag retrieval error: $e');
    }
  }

  Future<void> _syncBadges(int userId) async {
    try {
      _unlockedBadges = await emotionRepository.getBadgesForUser(userId);
      final drafts = _badgeService.evaluate(
        _moodHistory,
        unlockedCodes: _unlockedBadges.map((b) => b.code).toSet(),
      );
      for (final draft in drafts) {
        await emotionRepository.unlockBadge(
          code: draft.code,
          title: draft.title,
          description: draft.description,
          icon: draft.icon,
          userId: userId,
        );
      }
      if (drafts.isNotEmpty) {
        _unlockedBadges = await emotionRepository.getBadgesForUser(userId);
      }
    } catch (e) {
      debugPrint('Badge sync error: $e');
    }
  }

  // --- ANALYTICS (delegated to the pure MoodAnalytics service) ---

  double? getTodayAverage() => _analytics.todayAverage(_moodHistory);

  String getTodayStatusLabel() => _analytics.todayStatusLabel(_moodHistory);

  List<ChartPoint> getChartData() =>
      _analytics.chartData(_moodHistory, _selectedRange);

  int getStreak() => _analytics.streak(_moodHistory);

  int getLongestStreak() => _analytics.longestStreak(_moodHistory);

  int getActiveDays() => _analytics.activeDays(_moodHistory);

  // --- WEEKLY STATS (with previous-week comparison) ---

  double? getWeekAverage() => _analytics.weekAverage(_moodHistory);

  double? getPreviousWeekAverage() =>
      _analytics.weekAverage(_moodHistory, weeksBack: 1);

  double? getWeekAverageChange() =>
      MoodAnalytics.percentChange(getWeekAverage(), getPreviousWeekAverage());

  int getWeekCount() => _analytics.weekCount(_moodHistory);

  int getPreviousWeekCount() =>
      _analytics.weekCount(_moodHistory, weeksBack: 1);

  double? getWeekCountChange() => MoodAnalytics.percentChange(
    getWeekCount().toDouble(),
    getPreviousWeekCount().toDouble(),
  );

  int? getWeekPeak() => _analytics.weekPeak(_moodHistory);

  int? getPreviousWeekPeak() => _analytics.weekPeak(_moodHistory, weeksBack: 1);

  /// Point difference (this week vs previous week), null when not comparable.
  int? getWeekPeakDelta() {
    final current = getWeekPeak();
    final previous = getPreviousWeekPeak();
    if (current == null || previous == null) return null;
    return current - previous;
  }

  // --- MAINTENANCE ---

  Future<void> clearHistory(int userId) async {
    await emotionRepository.deleteAllEmotionsForUser(userId);
    _moodHistory = [];
    notifyListeners();
  }

  Future<void> clearHistoryBefore(int userId, DateTime date) async {
    await emotionRepository.deleteEmotionsBefore(userId, date);
    await fetchMoodHistory(userId);
  }

  Future<void> deleteEmotion(int id, int userId) async {
    await emotionRepository.deleteEmotion(id);
    await fetchMoodHistory(userId);
  }

  Future<bool> updateEmotion({
    required int id,
    required int userId,
    required int value,
    String? note,
    List<String>? tags,
    required DateTime createdAt,
  }) async {
    try {
      final success = await emotionRepository.updateEmotion(
        id: id,
        userId: userId,
        value: value,
        note: note,
        tags: tags,
        createdAt: createdAt,
      );
      await fetchMoodHistory(userId);
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<void> seedMockData(int userId) async {
    final random = Random();
    final now = DateTime.now();
    for (int i = 60; i >= 0; i--) {
      final entriesPerDay = random.nextInt(3) + 1;
      for (int j = 0; j < entriesPerDay; j++) {
        final date = now.subtract(
          Duration(
            days: i,
            hours: random.nextInt(24),
            minutes: random.nextInt(60),
          ),
        );
        await emotionRepository.addEmotion(
          userId: userId,
          value: random.nextInt(10) + 1,
          note: null,
          tags: null,
          createdAt: date,
        );
      }
    }
    await fetchMoodHistory(userId);
  }

  void _setLoading(bool value, {bool clearError = false}) {
    _isLoading = value;
    if (clearError) _errorMessage = null;
    notifyListeners();
  }
}
