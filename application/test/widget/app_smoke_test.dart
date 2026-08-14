import 'package:application/app/theme/app_theme.dart';
import 'package:application/app/pages/access/login_page.dart';
import 'package:application/app/pages/shell/main_navigation_container.dart';
import 'package:application/data/repositories/emotion_repository.dart';
import 'package:application/data/repositories/user_repository.dart';
import 'package:application/domain/models.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/mood_controller.dart';
import 'package:application/state/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockEmotionRepository extends Mock implements EmotionRepository {}

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
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider(
          create: (_) => RegisterController(userRepository: userRepository),
        ),
        ChangeNotifierProvider<MoodController>.value(value: moodController),
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
