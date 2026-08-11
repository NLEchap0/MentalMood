import 'package:application/domain/models.dart';

/// Back-end contract for emotion data. Implementations own the storage details.
abstract class EmotionRepository {
  Future<int> addEmotion({
    required int userId,
    required int value,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
  });

  Future<bool> updateEmotion({
    required int id,
    required int userId,
    required int value,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
  });

  Future<List<MoodEntry>> getEmotionsForUser(int userId);
  Future<void> deleteAllEmotionsForUser(int userId);
  Future<void> deleteEmotionsBefore(int userId, DateTime date);
  Future<void> deleteEmotion(int id);

  Future<List<MoodTag>> getTagsForUser(int userId);

  Future<void> unlockBadge({
    required String code,
    required String title,
    required String description,
    required String icon,
    required int userId,
  });

  Future<List<Badge>> getBadgesForUser(int userId);
}
