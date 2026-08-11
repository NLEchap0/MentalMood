import 'package:application/data/database/database.dart' hide MoodTag, Badge;
import 'package:application/data/database/mappers.dart';
import 'package:application/data/repositories/emotion_repository.dart';
import 'package:application/domain/models.dart';
import 'package:drift/drift.dart';

class DriftEmotionRepository implements EmotionRepository {
  final AppDataBase _db;

  DriftEmotionRepository(this._db);

  @override
  Future<int> addEmotion({
    required int userId,
    required int value,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return _db.addEmotion(
      emotionToCompanion(
        userId: userId,
        value: value,
        note: note,
        tags: tags,
        createdAt: createdAt,
      ),
    );
  }

  @override
  Future<bool> updateEmotion({
    required int id,
    required int userId,
    required int value,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return _db.updateEmotion(
      EmotionCompanion(
        id: Value(id),
        userId: Value(userId),
        value: Value(value),
        note: Value(note),
        tags: Value(tags == null || tags.isEmpty ? null : tags.join(',')),
        createdAt: Value(createdAt ?? DateTime.now()),
      ),
    );
  }

  @override
  Future<List<MoodEntry>> getEmotionsForUser(int userId) async {
    final rows = await _db.getEmotionsForUser(userId);
    return rows.map(emotionToDomain).toList();
  }

  @override
  Future<void> deleteAllEmotionsForUser(int userId) =>
      _db.deleteAllEmotionsForUser(userId);

  @override
  Future<void> deleteEmotionsBefore(int userId, DateTime date) =>
      _db.deleteEmotionsBefore(userId, date);

  @override
  Future<void> deleteEmotion(int id) => _db.deleteEmotion(id);

  @override
  Future<List<MoodTag>> getTagsForUser(int userId) async {
    final rows = await _db.getTagsForUser(userId);
    return rows.map(moodTagToDomain).toList();
  }

  @override
  Future<void> unlockBadge({
    required String code,
    required String title,
    required String description,
    required String icon,
    required int userId,
  }) {
    return _db.unlockBadge(
      BadgeCompanion.insert(
        code: code,
        title: title,
        description: description,
        icon: icon,
        userId: userId,
        unlockedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<List<Badge>> getBadgesForUser(int userId) async {
    final rows = await _db.getBadgesForUser(userId);
    return rows.map(badgeToDomain).toList();
  }
}
