import 'package:application/DataBase/database.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Repositories/emotion_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEmotionRepository extends Mock implements EmotionRepository {}

void main() {
  late MoodController moodController;
  late MockEmotionRepository mockEmotionRepository;

  setUpAll(() {
    registerFallbackValue(const EmotionCompanion());
    registerFallbackValue(const MoodTagCompanion());
    registerFallbackValue(const BadgeCompanion());
  });

  setUp(() {
    mockEmotionRepository = MockEmotionRepository();
    moodController = MoodController(emotionRepository: mockEmotionRepository);
    
    when(() => mockEmotionRepository.getEmotionsForUser(any()))
        .thenAnswer((_) async => []);
    when(() => mockEmotionRepository.getTagsForUser(any()))
        .thenAnswer((_) async => []);
    when(() => mockEmotionRepository.getBadgesForUser(any()))
        .thenAnswer((_) async => []);
  });

  group('MoodController Streak Logic', () {
    test('Streak is 0 when history is empty', () {
      expect(moodController.getStreak(), 0);
    });

    test('Streak is 1 when only today is recorded', () async {
      final now = DateTime.now();
      final history = [
        EmotionData(id: 1, value: 5, userId: 1, createdAt: now),
      ];
      
      when(() => mockEmotionRepository.getEmotionsForUser(1))
          .thenAnswer((_) async => history);
          
      await moodController.fetchMoodHistory(1);
      expect(moodController.getStreak(), 1);
    });

    test('Longest streak is correctly calculated', () async {
      final now = DateTime.now();
      final history = [
        EmotionData(id: 1, value: 5, userId: 1, createdAt: now),
        EmotionData(id: 2, value: 5, userId: 1, createdAt: now.subtract(const Duration(days: 1))),
        EmotionData(id: 3, value: 5, userId: 1, createdAt: now.subtract(const Duration(days: 4))),
        EmotionData(id: 4, value: 5, userId: 1, createdAt: now.subtract(const Duration(days: 5))),
        EmotionData(id: 5, value: 5, userId: 1, createdAt: now.subtract(const Duration(days: 6))),
      ];
      
      when(() => mockEmotionRepository.getEmotionsForUser(1))
          .thenAnswer((_) async => history);
          
      await moodController.fetchMoodHistory(1);
      expect(moodController.getLongestStreak(), 3);
    });
  });

  group('MoodController Achievement Logic', () {
    test('Unlocks streak badges correctly', () async {
      when(() => mockEmotionRepository.addEmotion(any())).thenAnswer((_) async => 1);
      when(() => mockEmotionRepository.unlockBadge(any())).thenAnswer((_) async => 1);
      
      final now = DateTime.now();
      final historyAfter = [
        EmotionData(id: 3, value: 5, userId: 1, createdAt: now),
        EmotionData(id: 1, value: 5, userId: 1, createdAt: now.subtract(const Duration(days: 1))),
        EmotionData(id: 2, value: 5, userId: 1, createdAt: now.subtract(const Duration(days: 2))),
      ];
      
      when(() => mockEmotionRepository.getEmotionsForUser(1))
          .thenAnswer((_) async => historyAfter);

      await moodController.saveMood(userId: 1, value: 5);
      
      final captured = verify(() => mockEmotionRepository.unlockBadge(captureAny())).captured;
      final badge = captured.first as BadgeCompanion;
      expect(badge.code.value, 'streak_3');
    });
  });

  group('MoodController Chart & Data Processing', () {
    test('Calculates today average correctly', () async {
      final now = DateTime.now();
      final history = [
        EmotionData(id: 1, value: 10, userId: 1, createdAt: now),
        EmotionData(id: 2, value: 2, userId: 1, createdAt: now.subtract(const Duration(minutes: 5))),
      ];
      
      when(() => mockEmotionRepository.getEmotionsForUser(1)).thenAnswer((_) async => history);
      await moodController.fetchMoodHistory(1);
      
      expect(moodController.getTodayAverage(), 6.0);
    });

    test('Provides correct status label for today', () async {
      final now = DateTime.now();
      final history = [
        EmotionData(id: 1, value: 10, userId: 1, createdAt: now),
      ];
      
      when(() => mockEmotionRepository.getEmotionsForUser(1)).thenAnswer((_) async => history);
      await moodController.fetchMoodHistory(1);
      
      final status = moodController.getTodayStatus();
      expect(status['label'], 'Zenith');
      expect(status['icon'], Icons.auto_awesome_rounded);
    });
  });
}
