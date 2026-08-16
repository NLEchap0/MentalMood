import 'package:application/data/repositories/emotion_repository.dart';
import 'package:application/domain/models.dart';
import 'package:application/state/mood_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEmotionRepository extends Mock implements EmotionRepository {}

void main() {
  late MoodController moodController;
  late MockEmotionRepository mockEmotionRepository;
  // Clock fisso per eliminare il flaky da mezzanotte: i test usano sempre
  // lo stesso "adesso", qualunque sia l'ora reale.
  final fixedNow = DateTime(2026, 6, 15, 12);

  setUp(() {
    mockEmotionRepository = MockEmotionRepository();
    moodController = MoodController(
      emotionRepository: mockEmotionRepository,
      now: () => fixedNow,
    );

    when(
      () => mockEmotionRepository.getEmotionsForUser(any()),
    ).thenAnswer((_) async => []);
    when(
      () => mockEmotionRepository.getTagsForUser(any()),
    ).thenAnswer((_) async => []);
    when(
      () => mockEmotionRepository.getBadgesForUser(any()),
    ).thenAnswer((_) async => []);
  });

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

  group('MoodController Streak Logic', () {
    test('Streak is 0 when history is empty', () {
      expect(moodController.getStreak(), 0);
    });

    test('Streak is 1 when only today is recorded', () async {
      final now = fixedNow;
      when(
        () => mockEmotionRepository.getEmotionsForUser(1),
      ).thenAnswer((_) async => [entry(1, 5, now)]);

      await moodController.fetchMoodHistory(1);
      expect(moodController.getStreak(), 1);
    });

    test('Longest streak is correctly calculated', () async {
      final now = fixedNow;
      when(() => mockEmotionRepository.getEmotionsForUser(1)).thenAnswer(
        (_) async => [
          entry(1, 5, now),
          entry(2, 5, now.subtract(const Duration(days: 1))),
          entry(3, 5, now.subtract(const Duration(days: 4))),
          entry(4, 5, now.subtract(const Duration(days: 5))),
          entry(5, 5, now.subtract(const Duration(days: 6))),
        ],
      );

      await moodController.fetchMoodHistory(1);
      expect(moodController.getLongestStreak(), 3);
    });
  });

  group('MoodController Achievement Logic', () {
    test('Unlocks streak badges correctly', () async {
      when(
        () => mockEmotionRepository.addEmotion(
          userId: any(named: 'userId'),
          value: any(named: 'value'),
          note: any(named: 'note'),
          tags: any(named: 'tags'),
        ),
      ).thenAnswer((_) async => 1);
      when(
        () => mockEmotionRepository.unlockBadge(
          code: any(named: 'code'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          icon: any(named: 'icon'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async {});

      final now = fixedNow;
      when(() => mockEmotionRepository.getEmotionsForUser(1)).thenAnswer(
        (_) async => [
          entry(3, 5, now),
          entry(1, 5, now.subtract(const Duration(days: 1))),
          entry(2, 5, now.subtract(const Duration(days: 2))),
        ],
      );

      await moodController.saveMood(userId: 1, value: 5);

      verify(
        () => mockEmotionRepository.unlockBadge(
          code: 'streak_3',
          title: any(named: 'title'),
          description: any(named: 'description'),
          icon: any(named: 'icon'),
          userId: 1,
        ),
      ).called(1);
    });
  });

  group('MoodController Chart & Data Processing', () {
    test('Calculates today average correctly', () async {
      final now = fixedNow;
      when(() => mockEmotionRepository.getEmotionsForUser(1)).thenAnswer(
        (_) async => [
          entry(1, 10, now),
          entry(2, 2, now.subtract(const Duration(minutes: 5))),
        ],
      );

      await moodController.fetchMoodHistory(1);

      expect(moodController.getTodayAverage(), 6.0);
    });

    test('Provides correct status label for today', () async {
      final now = fixedNow;
      when(
        () => mockEmotionRepository.getEmotionsForUser(1),
      ).thenAnswer((_) async => [entry(1, 10, now)]);

      await moodController.fetchMoodHistory(1);

      expect(moodController.getTodayStatusLabel(), 'Zenith');
    });

    test(
      'Chart data for 24h range includes entries from yesterday evening',
      () async {
        final now = fixedNow;
        final lateLastNight = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(hours: 2));
        when(
          () => mockEmotionRepository.getEmotionsForUser(1),
        ).thenAnswer((_) async => [entry(1, 6, lateLastNight)]);

        await moodController.fetchMoodHistory(1);
        moodController.setSelectedRange(MoodRange.last24h);

        final chart = moodController.getChartData();
        expect(chart, isNotEmpty);
        expect(chart.single.value, 6.0);
      },
    );
  });
}
