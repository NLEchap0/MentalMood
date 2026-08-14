import 'package:application/services/wearable_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWearableBridge extends Mock implements WearableBridge {}

void main() {
  late MockWearableBridge bridge;
  late WearableService service;

  setUp(() {
    bridge = MockWearableBridge();
    service = WearableService(bridge: bridge);
  });

  group('WearableService', () {
    test('last7DaysSleep sums and averages', () async {
      when(() => bridge.fetchSleep(
        from: any(named: 'from'),
        to: any(named: 'to'),
      )).thenAnswer((_) async => [
        SleepSample(start: DateTime.utc(2026, 1, 1, 22), end: DateTime.utc(2026, 1, 2, 6), hours: 8),
        SleepSample(start: DateTime.utc(2026, 1, 2, 22), end: DateTime.utc(2026, 1, 3, 5), hours: 7),
        SleepSample(start: DateTime.utc(2026, 1, 3, 22), end: DateTime.utc(2026, 1, 4, 6), hours: 9),
      ]);
      final stats = await service.last7DaysSleep(
        userId: 1,
        now: DateTime.utc(2026, 1, 8),
      );
      expect(stats.totalHours, closeTo(24, 0.01));
      expect(stats.avgHours, closeTo(8, 0.01));
      expect(stats.nights, 3);
    });

    test('last7DaysSteps sums and averages', () async {
      when(() => bridge.fetchSteps(
        from: any(named: 'from'),
        to: any(named: 'to'),
      )).thenAnswer((_) async => [
        StepSample(date: DateTime.utc(2026, 1, 1), steps: 8000),
        StepSample(date: DateTime.utc(2026, 1, 2), steps: 12000),
        StepSample(date: DateTime.utc(2026, 1, 3), steps: 10000),
      ]);
      final stats = await service.last7DaysSteps(
        userId: 1,
        now: DateTime.utc(2026, 1, 8),
      );
      expect(stats.totalSteps, 30000);
      expect(stats.avgSteps, closeTo(10000, 0.01));
      expect(stats.days, 3);
    });

    test('empty data returns zeros', () async {
      when(() => bridge.fetchSleep(from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) async => []);
      when(() => bridge.fetchSteps(from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) async => []);
      final sleep = await service.last7DaysSleep(userId: 1, now: DateTime.utc(2026, 1, 8));
      final steps = await service.last7DaysSteps(userId: 1, now: DateTime.utc(2026, 1, 8));
      expect(sleep.totalHours, 0);
      expect(sleep.nights, 0);
      expect(steps.totalSteps, 0);
      expect(steps.days, 0);
    });
  });
}
