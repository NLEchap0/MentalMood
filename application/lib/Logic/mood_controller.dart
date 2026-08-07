import 'dart:math';
import 'package:application/DataBase/database.dart';
import 'package:application/Repositories/emotion_repository.dart';
import 'package:application/Utils/theme.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum MoodRange { last24h, last7d, last30d, lastYear }

/// Pure Logic Layer for Mood Management.
/// Orchestrates data between Repositories and the UI.
class MoodController extends ChangeNotifier {
  final EmotionRepository emotionRepository;

  MoodController({required this.emotionRepository});

  // --- STATE ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<EmotionData> _moodHistory = [];
  List<EmotionData> get moodHistory => _moodHistory;

  List<MoodTagData> _availableTags = [];
  List<MoodTagData> get availableTags => _availableTags;

  List<BadgeData> _unlockedBadges = [];
  List<BadgeData> get unlockedBadges => _unlockedBadges;

  MoodRange _selectedRange = MoodRange.last7d;
  MoodRange get selectedRange => _selectedRange;
  
  bool _manuallySelected = false;

  // --- ACTIONS ---

  void setSelectedRange(MoodRange range) {
    _selectedRange = range;
    _manuallySelected = true;
    notifyListeners();
  }

  Future<bool> saveMood({
    required int userId,
    required int value,
    String? note,
    List<String>? tags,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await emotionRepository.addEmotion(EmotionCompanion.insert(
        value: value,
        userId: userId,
        createdAt: Value(DateTime.now()),
        note: Value(note),
        tags: Value(tags?.join(',')),
      ));
      
      await fetchMoodHistory(userId);
      await _checkAndUnlockBadges(userId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Neural sync failed. Connection unstable.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMoodHistory(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _moodHistory = await emotionRepository.getEmotionsForUser(userId);
      
      // Auto-fallback/Auto-promotion logic
      if (!_manuallySelected) {
        final now = DateTime.now();
        final weekCutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        final uniqueDaysInWeek = _moodHistory
            .where((e) => e.createdAt.isAfter(weekCutoff))
            .map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt))
            .toSet()
            .length;
        
        _selectedRange = (uniqueDaysInWeek >= 2) ? MoodRange.last7d : MoodRange.last24h;
      }

      await fetchAvailableTags(userId);
      await fetchUnlockedBadges(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "System logs inaccessible.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableTags(int userId) async {
    try {
      _availableTags = await emotionRepository.getTagsForUser(userId);
    } catch (e) {
      debugPrint("Tag retrieval error: $e");
    }
  }

  Future<void> fetchUnlockedBadges(int userId) async {
    try {
      _unlockedBadges = await emotionRepository.getBadgesForUser(userId);
    } catch (e) {
      debugPrint("Badge retrieval error: $e");
    }
  }

  // --- ANALYTICS ENGINE (Pure Middle-end Logic) ---

  double? getTodayAverage() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEntries = _moodHistory.where((e) => e.createdAt.isAfter(todayStart)).toList();
    if (todayEntries.isEmpty) return null;
    return todayEntries.map((e) => e.value).reduce((a, b) => a + b) / todayEntries.length;
  }

  Map<String, dynamic> getTodayStatus() {
    final avg = getTodayAverage();
    if (avg == null) return {"label": "Inactive", "icon": Icons.lens_blur_rounded, "color": Colors.white10};
    
    final int val = avg.round();
    final Color color = AppTheme.getSmoothColor(avg);
    final IconData icon = AppIcons.getMoodIcon(val);

    final labels = ['Dormant', 'Trace', 'Pulse', 'Core', 'Stasis', 'Flow', 'Active', 'Radiant', 'Vibrant', 'Zenith'];
    return {"label": labels[(val - 1).clamp(0, 9)], "icon": icon, "color": color};
  }

  List<ChartMoodPoint> getChartData() {
    if (_moodHistory.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoff;
    bool groupByDay = false;
    bool groupByMonth = false;

    switch (_selectedRange) {
      case MoodRange.last24h:
        cutoff = DateTime(now.year, now.month, now.day);
        groupByDay = false;
        break;
      case MoodRange.last7d:
        cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        groupByDay = true;
        break;
      case MoodRange.last30d:
        cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
        groupByDay = true;
        break;
      case MoodRange.lastYear:
        cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 364));
        groupByMonth = true;
        break;
    }

    final filtered = _moodHistory.where((e) => e.createdAt.isAfter(cutoff)).toList();
    filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (_selectedRange == MoodRange.last24h) {
      return filtered.map((e) => ChartMoodPoint(date: e.createdAt, value: e.value.toDouble())).toList();
    }

    if (groupByMonth) {
      final Map<String, List<double>> groups = {};
      for (var e in filtered) {
        final monthKey = DateFormat('yyyy-MM').format(e.createdAt);
        groups.putIfAbsent(monthKey, () => []).add(e.value.toDouble());
      }
      final List<ChartMoodPoint> result = [];
      groups.forEach((month, values) {
        result.add(ChartMoodPoint(date: DateTime.parse("$month-01"), value: values.reduce((a, b) => a + b) / values.length));
      });
      return result;
    }

    if (groupByDay) {
      final Map<String, List<double>> groups = {};
      for (var e in filtered) {
        final dayKey = DateFormat('yyyy-MM-dd').format(e.createdAt);
        groups.putIfAbsent(dayKey, () => []).add(e.value.toDouble());
      }
      final List<ChartMoodPoint> result = [];
      groups.forEach((day, values) {
        result.add(ChartMoodPoint(date: DateTime.parse(day), value: values.reduce((a, b) => a + b) / values.length));
      });
      return result;
    }
    return [];
  }

  String getMoodSummary() {
    if (_moodHistory.isEmpty) return "Neural network standby. No data for synthesis.";
    final latestMood = _moodHistory.first.value;
    if (latestMood <= 3) return "System alert: Low energy detected. Prioritize restoration.";
    if (latestMood <= 6) return "Node stable. Continuity maintaining standard parameters.";
    if (latestMood <= 8) return "Positive resonance confirmed. Performance optimal.";
    return "Peak performance detected. Zenith state achieved.";
  }

  int getStreak() {
    if (_moodHistory.isEmpty) return 0;
    final Set<String> daysRecorded = _moodHistory.map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt)).toSet();
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final yesterday = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

    if (!daysRecorded.contains(today) && !daysRecorded.contains(yesterday)) return 0;
    int streak = 0;
    DateTime checkDate = daysRecorded.contains(today) ? now : now.subtract(const Duration(days: 1));
    while (daysRecorded.contains(DateFormat('yyyy-MM-dd').format(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int getLongestStreak() {
    if (_moodHistory.isEmpty) return 0;
    final List<String> sortedDays = _moodHistory.map((e) => DateFormat('yyyy-MM-dd').format(e.createdAt)).toSet().toList()..sort();
    if (sortedDays.isEmpty) return 0;

    int longest = 0, current = 0;
    DateTime? lastDate;
    for (String dayStr in sortedDays) {
      DateTime date = DateTime.parse(dayStr);
      if (lastDate == null || date.difference(lastDate).inDays == 1) { current++; } 
      else { if (current > longest) longest = current; current = 1; }
      lastDate = date;
    }
    return current > longest ? current : longest;
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

  Future<bool> updateEmotion({required int id, required int userId, required int value, String? note, List<String>? tags, required DateTime createdAt}) async {
    try {
      final success = await emotionRepository.updateEmotion(EmotionCompanion(
        id: Value(id), userId: Value(userId), value: Value(value), note: Value(note), tags: Value(tags?.join(',')), createdAt: Value(createdAt),
      ));
      await fetchMoodHistory(userId);
      return success;
    } catch (e) { return false; }
  }

  Future<void> seedMockData(int userId) async {
    final Random random = Random();
    final now = DateTime.now();
    for (int i = 60; i >= 0; i--) {
      final entriesPerDay = random.nextInt(3) + 1;
      for (int j = 0; j < entriesPerDay; j++) {
        final date = now.subtract(Duration(days: i, hours: random.nextInt(24), minutes: random.nextInt(60)));
        await emotionRepository.addEmotion(EmotionCompanion.insert(value: random.nextInt(10) + 1, userId: userId, createdAt: Value(date)));
      }
    }
    await fetchMoodHistory(userId);
  }

  Future<void> _checkAndUnlockBadges(int userId) async {
    if (_moodHistory.isEmpty) return;
    final streak = getStreak();
    final totalEntries = _moodHistory.length;
    bool badgeAdded = false;

    Future<void> unlock(String code, String title, String desc, String icon) async {
      if (!_unlockedBadges.any((b) => b.code == code)) {
        await emotionRepository.unlockBadge(BadgeCompanion.insert(code: code, title: title, description: desc, icon: icon, userId: userId, unlockedAt: Value(DateTime.now())));
        badgeAdded = true;
      }
    }

    if (streak >= 7) await unlock('streak_7', 'Week Warrior', '7 day mood streak!', 'bolt');
    if (streak >= 30) await unlock('streak_30', 'Dedicated', '30 day mood streak!', 'diamond');
    if (totalEntries >= 50) await unlock('total_50', 'Mood Master', 'Logged 50 moods!', 'school');
    
    final noteCount = _moodHistory.where((e) => e.note != null && e.note!.isNotEmpty).length;
    if (noteCount >= 5) await unlock('notes_5', 'Journalist', 'Added notes to 5 entries', 'edit');

    if (_moodHistory.any((e) => e.createdAt.hour >= 5 && e.createdAt.hour <= 8)) await unlock('special_early', 'Early Bird', 'Morning check-in', 'morning');
    if (_moodHistory.any((e) => e.createdAt.hour >= 0 && e.createdAt.hour <= 4)) await unlock('special_night', 'Night Owl', 'Late night log', 'night');
    if (badgeAdded) await fetchUnlockedBadges(userId);
  }
}

class ChartMoodPoint {
  final DateTime date;
  final double value;
  ChartMoodPoint({required this.date, required this.value});
}
