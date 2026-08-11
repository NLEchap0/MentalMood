import 'package:application/data/database/database.dart' hide MoodTag, Badge;
import 'package:application/domain/models.dart';
import 'package:drift/drift.dart';

/// Conversions between Drift row classes and pure domain models.
/// This is the ONLY place that knows both worlds.

MoodEntry emotionToDomain(EmotionData row) => MoodEntry(
  id: row.id,
  value: row.value,
  userId: row.userId,
  createdAt: row.createdAt,
  note: row.note,
  tags: row.tags == null
      ? const []
      : row.tags!
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
);

EmotionCompanion emotionToCompanion({
  required int userId,
  required int value,
  String? note,
  List<String>? tags,
  DateTime? createdAt,
}) => EmotionCompanion.insert(
  value: value,
  userId: userId,
  createdAt: Value(createdAt ?? DateTime.now()),
  note: Value(note),
  tags: Value(tags == null || tags.isEmpty ? null : tags.join(',')),
);

MoodTag moodTagToDomain(MoodTagData row) =>
    MoodTag(id: row.id, label: row.label, emoji: row.emoji);

Badge badgeToDomain(BadgeData row) => Badge(
  id: row.id,
  code: row.code,
  title: row.title,
  description: row.description,
  icon: row.icon,
  unlockedAt: row.unlockedAt,
);

AppUser userToDomain(UserData row) => AppUser(
  id: row.id,
  username: row.username,
  name: row.name,
  surname: row.surname,
  birthDate: row.birthDate,
  passwordHash: row.password,
);

UserCompanion userToCompanion({
  required String username,
  required String name,
  required String surname,
  required String password,
  required DateTime birthDate,
}) => UserCompanion.insert(
  username: username,
  name: name,
  surname: surname,
  password: password,
  birthDate: birthDate,
);
