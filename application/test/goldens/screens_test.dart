import 'package:application/app/pages/growth/streak_stats_page.dart';
import 'package:application/app/pages/growth/zen_mode_page.dart';
import 'package:application/app/pages/journal/add_mood_page.dart';
import 'package:application/app/pages/journal/mood_history_page.dart';
import 'package:application/app/pages/shell/main_navigation_container.dart';
import 'package:application/app/theme/app_theme.dart';
import 'package:application/data/repositories/emotion_repository.dart';
import 'package:application/data/repositories/user_repository.dart';
import 'package:application/data/secure/secure_key_store.dart';
import 'package:application/domain/models.dart';
import 'package:application/domain/services/crypto_service.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/services/checkin_scheduler.dart';
import 'package:application/services/sync_http_client.dart';
import 'package:application/services/sync_service.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:application/state/mood_controller.dart';
import 'package:application/state/register_controller.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Screenshot capture of the REAL app UI.
/// Regenerate with:  flutter test --update-goldens test/goldens/screens_test.dart
/// Output: test/goldens/*.png  → copied to the website images/.

class FakeUserRepository implements UserRepository {
  final AppUser user;
  FakeUserRepository(this.user);

  @override
  Future<AppUser?> getUserByUsername(String username) async => user;

  @override
  Future<AppUser> createUser({
    required String username,
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
  }) async =>
      true;

  @override
  Future<int> deleteUser(int userId) async => 1;
}

class FakeEmotionRepository implements EmotionRepository {
  final List<MoodEntry> entries;
  final List<MoodTag> tags;
  final List<Badge> badges;

  FakeEmotionRepository({required this.entries, required this.tags, required this.badges});

  @override
  Future<int> addEmotion({
    required int userId,
    required int value,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
  }) async =>
      100;

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
  Future<List<MoodEntry>> getEmotionsForUser(int userId) async => entries;

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
  Future<List<Badge>> getBadgesForUser(int userId) async => badges;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthController auth;
  late MoodController mood;

  Future<void> loadGeist() async {
    for (final weight in [400, 500, 600, 700, 800]) {
      final data =
          await rootBundle.load('assets/fonts/Geist-$weight.ttf');
      final loader = FontLoader('Geist')..addFont(Future.value(data));
      await loader.load();
    }
  }

  List<MoodEntry> seedHistory() {
    final now = DateTime.now();
    final entries = <MoodEntry>[];
    var id = 1;
    // 21 days of realistic history (deterministic).
    for (var day = 21; day >= 0; day--) {
      final date = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: day));
      final value = 4 + (day * 3) % 6; // 4..9
      entries.add(MoodEntry(
        id: id++,
        value: value,
        userId: 1,
        createdAt: date.add(Duration(hours: 8, minutes: 30)),
        note: day.isEven ? null : 'A note for day $day.',
        tags: day % 3 == 0 ? const ['Work'] : const [],
      ));
      if (day == 0 || day == 2 || day == 5) {
        entries.add(MoodEntry(
          id: id++,
          value: value + 2 > 10 ? 10 : value + 2,
          userId: 1,
          createdAt: date.add(const Duration(hours: 21, minutes: 10)),
          tags: const ['Family'],
        ));
      }
    }
    return entries;
  }

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await loadGeist();

    final user = AppUser(
      id: 1,
      username: 'alex',
      name: 'Alex',
      surname: 'Mood',
      birthDate: DateTime(1998, 5, 12),
      passwordHash: 'hash',
    );
    final userRepo = FakeUserRepository(user);
    final emotionRepo = FakeEmotionRepository(
      entries: seedHistory(),
      tags: const [
        MoodTag(id: 1, label: 'Work', emoji: 'work'),
        MoodTag(id: 2, label: 'Family', emoji: 'family'),
        MoodTag(id: 3, label: 'Sleep', emoji: 'sleep'),
      ],
      badges: const [
        Badge(id: 1, code: 'streak_3', title: 'Rising Star', description: '3 day streak', icon: 'bolt', unlockedAt: null),
        Badge(id: 2, code: 'streak_7', title: 'Week Warrior', description: '7 day streak', icon: 'bolt', unlockedAt: null),
        Badge(id: 3, code: 'notes_5', title: 'Journalist', description: 'Notes on 5 entries', icon: 'edit', unlockedAt: null),
      ],
    );

    auth = AuthController(userRepository: userRepo);
    await auth.startSession(user);
    mood = MoodController(emotionRepository: emotionRepo);
  });

  Widget wrap(Widget child) {
    return MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: auth.userRepository),
        Provider<EmotionRepository>.value(value: mood.emotionRepository),
        ChangeNotifierProvider<AuthController>.value(value: auth),
        ChangeNotifierProvider<RegisterController>(
            create: (_) => RegisterController(userRepository: auth.userRepository)),
        ChangeNotifierProvider<MoodController>.value(value: mood),
        Provider<SecureKeyStore>.value(value: _InMemoryKeyStore()),
        Provider<CryptoService>.value(
            value: CryptoService(pbkdf2Iterations: 1000)),
        ChangeNotifierProvider<CloudController>.value(
          value: CloudController(
            apiClient: AuthApiClient(),
            keyStore: _InMemoryKeyStore(),
            crypto: CryptoService(pbkdf2Iterations: 1000),
          ),
        ),
        ChangeNotifierProvider<SyncService>.value(
          value: SyncService(
            emotionRepository: mood.emotionRepository,
            httpClient: HttpSyncClient(),
            crypto: CryptoService(pbkdf2Iterations: 1000),
          ),
        ),
        Provider<CheckinScheduler>.value(
          value: CheckinScheduler(
            notifications: _NoopNotifications(),
            now: DateTime.now,
          ),
        ),
      ],
      child: MaterialApp(theme: AppTheme.theme, home: child),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  void phoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532); // 390x844 @3x
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('capture home (shell)', (tester) async {
    phoneViewport(tester);
    await tester.pumpWidget(wrap(const MainNavigationContainer()));
    await settle(tester);
    await expectLater(
        find.byType(MainNavigationContainer), matchesGoldenFile('goldens/home.png'));
  });

  testWidgets('capture add mood', (tester) async {
    phoneViewport(tester);
    await tester.pumpWidget(wrap(const AddMoodPage()));
    await settle(tester);
    await expectLater(find.byType(AddMoodPage), matchesGoldenFile('goldens/add_mood.png'));
  });

  testWidgets('capture zen', (tester) async {
    phoneViewport(tester);
    await tester.pumpWidget(wrap(const ZenModePage()));
    await settle(tester);
    await expectLater(find.byType(ZenModePage), matchesGoldenFile('goldens/zen.png'));
  });

  testWidgets('capture consistency', (tester) async {
    phoneViewport(tester);
    await tester.pumpWidget(wrap(const StreakStatsPage()));
    await settle(tester);
    await expectLater(
        find.byType(StreakStatsPage), matchesGoldenFile('goldens/streak.png'));
  });

  testWidgets('capture journal', (tester) async {
    phoneViewport(tester);
    await tester.pumpWidget(wrap(const MoodHistoryPage()));
    await settle(tester);
    await expectLater(
        find.byType(MoodHistoryPage), matchesGoldenFile('goldens/journal.png'));
  });
}

class _InMemoryKeyStore implements SecureKeyStore {
  final _map = <String, String>{};

  @override
  Future<void> write(String key, String value) async => _map[key] = value;

  @override
  Future<String?> read(String key) async => _map[key];

  @override
  Future<void> delete(String key) async => _map.remove(key);
}

class _NoopNotifications implements NotificationService {
  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleDaily({
    required int id,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}
