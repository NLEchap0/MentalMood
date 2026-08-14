import 'package:application/services/checkin_scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNotificationService notifications;
  late CheckinScheduler scheduler;

  setUpAll(() {
    registerFallbackValue(const TimeOfDay(hour: 8, minute: 0));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    notifications = MockNotificationService();
    scheduler = CheckinScheduler(
      notifications: notifications,
      now: () => DateTime.utc(2026, 1, 1, 8),
    );
  });

  group('CheckinScheduler', () {
    test('enable saves pref and schedules daily notification', () async {
      when(() => notifications.requestPermission()).thenAnswer((_) async => true);
      when(() => notifications.scheduleDaily(
        id: any(named: 'id'),
        time: any(named: 'time'),
        title: any(named: 'title'),
        body: any(named: 'body'),
      )).thenAnswer((_) async {});

      final ok = await scheduler.enable(
        time: const TimeOfDay(hour: 20, minute: 0),
        userId: 7,
      );

      expect(ok, true);
      verify(() => notifications.scheduleDaily(
        id: 7,
        time: const TimeOfDay(hour: 20, minute: 0),
        title: any(named: 'title'),
        body: any(named: 'body'),
      )).called(1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('checkin_7'), contains('20:00'));
    });

    test('enable returns false when permission denied', () async {
      when(() => notifications.requestPermission()).thenAnswer((_) async => false);
      final ok = await scheduler.enable(
        time: const TimeOfDay(hour: 20, minute: 0),
        userId: 1,
      );
      expect(ok, false);
      verifyNever(() => notifications.scheduleDaily(
        id: any(named: 'id'),
        time: any(named: 'time'),
        title: any(named: 'title'),
        body: any(named: 'body'),
      ));
    });

    test('disable cancels notification and removes pref', () async {
      SharedPreferences.setMockInitialValues({'checkin_7': '{"enabled":true,"time":"20:00"}'});
      when(() => notifications.cancel(7)).thenAnswer((_) async {});

      await scheduler.disable(7);

      verify(() => notifications.cancel(7)).called(1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('checkin_7'), isNull);
    });

    test('getTime returns null when disabled', () async {
      expect(await scheduler.getTime(7), isNull);
    });

    test('getTime returns stored time', () async {
      SharedPreferences.setMockInitialValues({'checkin_7': '{"enabled":true,"time":"20:00"}'});
      final t = await scheduler.getTime(7);
      expect(t, isNotNull);
      expect(t!.hour, 20);
      expect(t.minute, 0);
    });
  });
}
