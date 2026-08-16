import 'package:application/app/theme/app_theme.dart';
import 'package:application/app/pages/access/login_page.dart';
import 'package:application/app/pages/shell/main_navigation_container.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockEmotionRepository extends Mock implements EmotionRepository {}

class InMemoryKeyStore implements SecureKeyStore {
  final _map = <String, String>{};

  @override
  Future<void> write(String key, String value) async => _map[key] = value;

  @override
  Future<String?> read(String key) async => _map[key];

  @override
  Future<void> delete(String key) async => _map.remove(key);
}

void main() {
  setUpAll(() {
    // Geist is bundled in the app bundle; no runtime font fetching.
  });

  late MockUserRepository userRepository;
  late MockEmotionRepository emotionRepository;
  late AuthController authController;
  late MoodController moodController;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    userRepository = MockUserRepository();
    emotionRepository = MockEmotionRepository();

    when(
      () => userRepository.getUserByUsername(any()),
    ).thenAnswer((_) async => null);
    when(
      () => emotionRepository.getEmotionsForUser(any()),
    ).thenAnswer((_) async => []);
    when(
      () => emotionRepository.getTagsForUser(any()),
    ).thenAnswer((_) async => []);
    when(
      () => emotionRepository.getBadgesForUser(any()),
    ).thenAnswer((_) async => []);

    authController = AuthController(userRepository: userRepository);
    moodController = MoodController(emotionRepository: emotionRepository);
  });

  Widget wrap(Widget child) {
    return MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: userRepository),
        Provider<EmotionRepository>.value(value: emotionRepository),
        Provider<SecureKeyStore>.value(value: InMemoryKeyStore()),
        Provider<CryptoService>.value(
          value: CryptoService(pbkdf2Iterations: 1000),
        ),
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider<CloudController>.value(
          value: CloudController(
            apiClient: AuthApiClient(),
            keyStore: InMemoryKeyStore(),
            crypto: CryptoService(pbkdf2Iterations: 1000),
            userRepository: userRepository,
            authController: authController,
          ),
        ),
        ChangeNotifierProvider<SyncService>.value(
          value: SyncService(
            emotionRepository: emotionRepository,
            httpClient: HttpSyncClient(),
            crypto: CryptoService(pbkdf2Iterations: 1000),
          ),
        ),
        ChangeNotifierProvider<MoodController>.value(value: moodController),
        Provider<CheckinScheduler>.value(
          value: CheckinScheduler(
            notifications: _NoopNotificationService(),
            now: DateTime.now,
          ),
        ),
      ],
      child: MaterialApp(theme: AppTheme.theme, home: child),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    // Flush FadeInSlide delayed entrance timers.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  testWidgets('Login page renders without exceptions', (tester) async {
    await tester.pumpWidget(wrap(const LoginPage()));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('MentalMood'), findsOneWidget);
  });

  testWidgets('Main shell renders all tabs without exceptions', (tester) async {
    // Simulate a logged-in user so the shell loads history/tags on mount.
    await authController.startSession(
      AppUser(
        id: 1,
        username: 'tester',
        name: 'Test',
        surname: 'User',
        birthDate: DateTime(2000),
        passwordHash: 'hash',
      ),
    );

    await tester.pumpWidget(wrap(const MainNavigationContainer()));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Add Check-in'), findsWidgets);

    // Mood history (and thus tags/badges) is loaded on shell mount.
    verify(() => emotionRepository.getEmotionsForUser(1)).called(1);

    // Journal tab (empty state)
    await tester.tap(find.text('Journal'));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('YOUR JOURNAL IS EMPTY'), findsOneWidget);

    // Profile tab (ListTile tiles)
    await tester.tap(find.text('Profile'));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('PERSONAL INFO'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);

    // Back to Home
    await tester.tap(find.text('Home'));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Add Check-in flow opens without exceptions', (tester) async {
    await tester.pumpWidget(wrap(const MainNavigationContainer()));
    await settle(tester);

    // The action pill is the shared AppButton (the chart CTA is another one).
    await tester.tap(find.byKey(const Key('shell_add_checkin')));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('New Check-in'), findsOneWidget);
  });

  testWidgets('Home chart empty state renders without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const MainNavigationContainer()));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('NO DATA YET'), findsOneWidget);
    expect(find.text('Add Check-in'), findsWidgets);
  });

  testWidgets('Pull-to-refresh reloads mood history', (tester) async {
    var fetchCalls = 0;
    when(() => emotionRepository.getEmotionsForUser(any())).thenAnswer((
      _,
    ) async {
      fetchCalls++;
      return [];
    });

    await authController.startSession(
      AppUser(
        id: 1,
        username: 'tester',
        name: 'Test',
        surname: 'User',
        birthDate: DateTime(2000),
        passwordHash: 'hash',
      ),
    );

    await tester.pumpWidget(wrap(const MainNavigationContainer()));
    await settle(tester);

    verify(() => emotionRepository.getEmotionsForUser(1)).called(1);

    // Trigger the pull-to-refresh callback and verify data is reloaded.
    // (The gesture → RefreshIndicator wiring itself is covered by Flutter's
    // own RefreshIndicator tests.)
    final indicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator).first,
    );
    await indicator.onRefresh();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(fetchCalls, 2);
  });
}

class _NoopNotificationService implements NotificationService {
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
