class SleepSample {
  const SleepSample({
    required this.start,
    required this.end,
    required this.hours,
  });

  final DateTime start;
  final DateTime end;
  final double hours;
}

class StepSample {
  const StepSample({required this.date, required this.steps});

  final DateTime date;
  final int steps;
}

class SleepStats {
  const SleepStats({
    required this.totalHours,
    required this.avgHours,
    required this.nights,
  });
  final double totalHours;
  final double avgHours;
  final int nights;
}

class StepStats {
  const StepStats({
    required this.totalSteps,
    required this.avgSteps,
    required this.days,
  });
  final int totalSteps;
  final double avgSteps;
  final int days;
}

abstract class WearableBridge {
  Future<List<SleepSample>> fetchSleep({
    required DateTime from,
    required DateTime to,
  });
  Future<List<StepSample>> fetchSteps({
    required DateTime from,
    required DateTime to,
  });
}

class WearableService {
  WearableService({required this._bridge});

  final WearableBridge _bridge;

  Future<SleepStats> last7DaysSleep({
    required int userId,
    required DateTime now,
  }) async {
    final from = now.subtract(const Duration(days: 7));
    final samples = await _bridge.fetchSleep(from: from, to: now);
    final nights = samples.length;
    final total = samples.fold<double>(0, (a, s) => a + s.hours);
    return SleepStats(
      totalHours: total,
      avgHours: nights == 0 ? 0 : total / nights,
      nights: nights,
    );
  }

  Future<StepStats> last7DaysSteps({
    required int userId,
    required DateTime now,
  }) async {
    final from = now.subtract(const Duration(days: 7));
    final samples = await _bridge.fetchSteps(from: from, to: now);
    final days = samples.length;
    final total = samples.fold<int>(0, (a, s) => a + s.steps);
    return StepStats(
      totalSteps: total,
      avgSteps: days == 0 ? 0 : total / days,
      days: days,
    );
  }
}
