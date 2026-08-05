import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:application/Utils/constants.dart';

part 'database.g.dart';

class User extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text()();
  TextColumn get name => text()();
  TextColumn get surname => text()();
  TextColumn get password => text()();
  DateTimeColumn get birthDate => dateTime()();
}

class Emotion extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get value => integer().check(value.isBetweenValues(1, 10))();
  IntColumn get userId => integer().references(User, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get note => text().nullable()();
  TextColumn get tags => text().nullable()();
}

class MoodTag extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text().withLength(min: 1, max: 20)();
  TextColumn get emoji => text().withLength(min: 1, max: 30)();
  IntColumn get userId => integer().nullable().references(User, #id, onDelete: KeyAction.cascade)(); // null means global/default
}

class Badge extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()(); // e.g. 'streak_7', 'total_50'
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get icon => text()(); // Emoji or icon name
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  IntColumn get userId => integer().references(User, #id, onDelete: KeyAction.cascade)();
}

@DriftDatabase(tables: [User, Emotion, MoodTag, Badge])
class AppDataBase extends _$AppDataBase {
  AppDataBase() : super(_openConnection());
  AppDataBase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 5;

  // User operations
  Future<int> createUser(UserCompanion entity) => into(user).insert(entity);
  Future<UserData?> getUser(String username) =>
      (select(user)..where((u) => u.username.equals(username))).getSingleOrNull();

  Future<bool> updateUser(UserCompanion entity) => update(user).replace(entity);
  Future<int> deleteUser(int userId) => (delete(user)..where((u) => u.id.equals(userId))).go();

  // Emotion operations
  Future<int> addEmotion(EmotionCompanion entity) => into(emotion).insert(entity);
  Future<bool> updateEmotion(EmotionCompanion entity) => update(emotion).replace(entity);
  Future<List<EmotionData>> getEmotionsForUser(int userId) =>
      (select(emotion)..where((e) => e.userId.equals(userId))..orderBy([(e) => OrderingTerm.desc(e.createdAt)])).get();

  Future<void> deleteAllEmotionsForUser(int userId) =>
      (delete(emotion)..where((e) => e.userId.equals(userId))).go();

  Future<void> deleteEmotionsBefore(int userId, DateTime date) =>
      (delete(emotion)..where((e) => e.userId.equals(userId) & e.createdAt.isSmallerThanValue(date))).go();

  Future<void> deleteEmotion(int id) => (delete(emotion)..where((e) => e.id.equals(id))).go();

  // Tag operations
  Future<int> addTag(MoodTagCompanion entity) => into(moodTag).insert(entity);
  Future<List<MoodTagData>> getTagsForUser(int userId) =>
      (select(moodTag)..where((t) => t.userId.isNull() | t.userId.equals(userId))).get();
  Future<int> deleteTag(int id) => (delete(moodTag)..where((t) => t.id.equals(id))).go();

  // Badge operations
  Future<int> unlockBadge(BadgeCompanion entity) => into(badge).insert(entity, mode: InsertMode.insertOrReplace);
  Future<List<BadgeData>> getBadgesForUser(int userId) =>
      (select(badge)..where((b) => b.userId.equals(userId))).get();

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(emotion);
        } else if (from < 3) {
          // Add columns only if we are coming from a version that didn't have them
          // and the table was already created in its old state.
          await m.addColumn(emotion, emotion.note);
          await m.addColumn(emotion, emotion.tags);
        }
        if (from < 4) await m.createTable(moodTag);
        if (from < 5) await m.createTable(badge);
      },
      beforeOpen: (details) async {
        // Seed tags if empty
        final tags = await select(moodTag).get();
        if (tags.isEmpty) {
          final defaultTags = [
            {'label': 'Work', 'emoji': '💼'},
            {'label': 'Sport', 'emoji': '🏃‍♂️'},
            {'label': 'Food', 'emoji': '🍎'},
            {'label': 'Sleep', 'emoji': '😴'},
            {'label': 'Family', 'emoji': '👨‍👩‍👧'},
            {'label': 'Friends', 'emoji': '🤝'},
            {'label': 'Hobby', 'emoji': '🎨'},
            {'label': 'Weather', 'emoji': '☀️'},
          ];
          for (var tag in defaultTags) {
            await into(moodTag).insert(MoodTagCompanion.insert(
              label: tag['label']!,
              emoji: tag['emoji']!,
            ));
          }
        }

        // Seed default user
        final users = await select(user).get();
        if (users.isEmpty) {
          await into(user).insert(UserCompanion.insert(
            username: AppConstants.adminUsername,
            name: 'Default',
            surname: 'User',
            password: AppConstants.hashedAdminPassword,
            birthDate: DateTime.now(),
          ));
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
