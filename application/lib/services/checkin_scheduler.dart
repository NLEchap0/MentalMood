import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NotificationService {
  Future<bool> requestPermission();
  Future<void> scheduleDaily({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  });
  Future<void> cancel(int id);
}

class CheckinScheduler {
  CheckinScheduler({
    required this._notifications,
    required DateTime Function() now,
  });

  final NotificationService _notifications;

  Future<bool> enable({
    required TimeOfDay time,
    required int userId,
  }) async {
    final granted = await _notifications.requestPermission();
    if (!granted) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'checkin_$userId',
      jsonEncode({
        'enabled': true,
        'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      }),
    );
    await _notifications.scheduleDaily(
      id: userId,
      time: time,
      title: 'Come ti senti oggi?',
      body: 'Un check-in di 10 secondi per tracciare il tuo umore.',
    );
    return true;
  }

  Future<void> disable(int userId) async {
    await _notifications.cancel(userId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('checkin_$userId');
  }

  Future<TimeOfDay?> getTime(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('checkin_$userId');
    if (raw == null) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final parts = (data['time'] as String).split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
