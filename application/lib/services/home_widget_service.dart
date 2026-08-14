import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class HomeWidgetBridge {
  Future<void> updateMood(int value, String emoji);
}

class HomeWidgetService {
  HomeWidgetService({
    required this._bridge,
    required this._now,
  });

  final HomeWidgetBridge _bridge;
  final DateTime Function() _now;

  Future<void> pushMood({required int userId, required int value}) async {
    if (value < 1 || value > 10) {
      throw ArgumentError.value(value, 'value', 'must be 1-10');
    }
    final emoji = switch (value) {
      <= 3 => '😞',
      <= 7 => '😐',
      _ => '😊',
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'widget_mood',
      jsonEncode({
        'value': value,
        'emoji': emoji,
        'updated_at': _now().toUtc().toIso8601String(),
      }),
    );
    await _bridge.updateMood(value, emoji);
  }
}
