import 'package:application/app/pages/journal/add_mood_page.dart';
import 'package:application/app/theme/app_icons.dart';
import 'package:application/app/theme/app_theme.dart';
import 'package:application/data/repositories/emotion_repository.dart';
import 'package:application/data/repositories/user_repository.dart';
import 'package:application/domain/models.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/mood_controller.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeUserRepository implements UserRepository {
  final AppUser user;
  FakeUserRepository(this.user);

  @override
  Future<AppUser?> getUserByUsername(String username) async => user;

  @override
  Future<AppUser> createUser({
    required String username,
    String? email,
    required String name,
    required String surname,
    required String password,
    required DateTime birthDate,
  }) async =>
      user;

  @override
  Future<bool> updateUser({
    required int id,
    required String name,
    required String surname,
    required DateTime birthDate,
    String? email,
  }) async =>
      true;

  @override
  Future<int> deleteUser(int userId) async => 1;
}

class FakeEmotionRepository implements EmotionRepository {
  final List<MoodTag> tags;
  FakeEmotionRepository(this.tags);

  @override
  Future<int> addEmotion({
    required int userId,
    required int value,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
  }) async =>
      1;

  @override
  Future<bool> updateEmotion({
    required int id,
    required int userId,
    required int value,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
  }) async =>
      true;

  @override
  Future<List<MoodEntry>> getEmotionsForUser(int userId) async => [];

  @override
  Future<void> deleteAllEmotionsForUser(int userId) async {}

  @override
  Future<void> deleteEmotionsBefore(int userId, DateTime date) async {}

  @override
  Future<void> deleteEmotion(int id) async {}

  @override
  Future<List<MoodTag>> getTagsForUser(int userId) async => tags;

  @override
  Future<void> unlockBadge({
    required String code,
    required String title,
    required String description,
    required String icon,
    required int userId,
  }) async {}

  @override
  Future<List<Badge>> getBadgesForUser(int userId) async => [];
}

void main() {
  testWidgets('add mood tag chips render icons', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final user = AppUser(
      id: 1,
      username: 'alex',
      name: 'Alex',
      surname: 'Mood',
      birthDate: DateTime(1998),
      passwordHash: 'hash',
    );
    final auth = AuthController(userRepository: FakeUserRepository(user));
    await auth.startSession(user);
    final mood = MoodController(
      emotionRepository: FakeEmotionRepository(const [
        MoodTag(id: 1, label: 'Work', emoji: 'work'),
        MoodTag(id: 2, label: 'Family', emoji: 'family'),
        MoodTag(id: 3, label: 'Sleep', emoji: 'sleep'),
      ]),
    );
    await mood.fetchMoodHistory(1);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<UserRepository>.value(value: auth.userRepository),
          Provider<EmotionRepository>.value(value: mood.emotionRepository),
          ChangeNotifierProvider<AuthController>.value(value: auth),
          ChangeNotifierProvider<MoodController>.value(value: mood),
        ],
        child: MaterialApp(theme: AppTheme.theme, home: const AddMoodPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Work'), findsOneWidget);
    expect(find.byIcon(AppIcons.fromString('work')), findsOneWidget);
    expect(find.byIcon(AppIcons.fromString('family')), findsOneWidget);
    expect(find.byIcon(AppIcons.fromString('sleep')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('emoji tag values map to the right icons', () {
    // Existing databases store real emoji instead of string keys.
    expect(AppIcons.fromString('💼'), Icons.work_outline_rounded);
    expect(AppIcons.fromString('🍎'), Icons.restaurant_rounded);
    expect(AppIcons.fromString('😴'), Icons.bedtime_outlined);
    expect(AppIcons.fromString('🏃\u200d♂️'), Icons.fitness_center_rounded);
    expect(AppIcons.fromString('unknown-thing'), Icons.label_important_outline_rounded);
  });
}
