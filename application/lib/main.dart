import 'package:application/DataBase/database.dart';
import 'package:application/Logic/login_controller.dart';
import 'package:application/Logic/mood_controller.dart';
import 'package:application/Logic/register_controller.dart';
import 'package:application/Pages/Access/login.dart';
import 'package:application/Pages/Mood/achievements_page.dart';
import 'package:application/Pages/Mood/mood_history_page.dart';
import 'package:application/Pages/Mood/streak_stats_page.dart';
import 'package:application/Pages/Mood/zen_mode_page.dart';
import 'package:application/Pages/main_navigation_container.dart';
import 'package:application/Pages/Settings/settings_page.dart';
import 'package:application/Repositories/drift_emotion_repository.dart';
import 'package:application/Repositories/drift_user_repository.dart';
import 'package:application/Repositories/emotion_repository.dart';
import 'package:application/Repositories/user_repository.dart';
import 'package:application/Utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Intl.defaultLocale = 'en_GB'; // Force English with European-style dates
  await initializeDateFormatting('en_GB', null);

  final db = AppDataBase();
  final userRepository = DriftUserRepository(db);
  final emotionRepository = DriftEmotionRepository(db);
  final loginController = LoginController(userRepository: userRepository);

  final bool loggedIn = await loginController.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDataBase>.value(value: db),
        Provider<UserRepository>.value(value: userRepository),
        Provider<EmotionRepository>.value(value: emotionRepository),
        ChangeNotifierProvider<LoginController>.value(value: loginController),
        ChangeNotifierProvider(create: (_) => RegisterController(userRepository: userRepository)),
        ChangeNotifierProvider(create: (_) => MoodController(emotionRepository: emotionRepository)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        themeMode: ThemeMode.dark, // Force a single, premium dark experience
        locale: const Locale('en', 'GB'),
        supportedLocales: const [Locale('en', 'GB')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: loggedIn ? const MainNavigationContainer() : const Login(),
        routes: {
          '/login': (context) => const Login(),
          '/home': (context) => const MainNavigationContainer(),
          '/settings': (context) => const SettingsPage(),
          '/history': (context) => const MoodHistoryPage(),
          '/streak': (context) => const StreakStatsPage(),
          '/achievements': (context) => const AchievementsPage(),
          '/zen': (context) => const ZenModePage(),
        },
      ),
    ),
  );
}
