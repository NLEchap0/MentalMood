import 'package:application/app/navigation/app_navigator.dart';
import 'package:application/app/pages/access/login_page.dart';
import 'package:application/app/pages/access/register_page.dart';
import 'package:application/app/pages/shell/main_navigation_container.dart';
import 'package:application/app/theme/app_theme.dart';
import 'package:application/data/database/database.dart';
import 'package:application/data/repositories/drift_emotion_repository.dart';
import 'package:application/data/repositories/drift_user_repository.dart';
import 'package:application/data/repositories/emotion_repository.dart';
import 'package:application/data/repositories/user_repository.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/mood_controller.dart';
import 'package:application/state/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Environment file not found or invalid: $e');
  }
  Intl.defaultLocale = 'en_GB';
  await initializeDateFormatting('en_GB', null);

  final db = AppDataBase();
  final userRepository = DriftUserRepository(db);
  final emotionRepository = DriftEmotionRepository(db);
  final authController = AuthController(userRepository: userRepository);

  final bool loggedIn = await authController.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: userRepository),
        Provider<EmotionRepository>.value(value: emotionRepository),
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider(
          create: (_) => RegisterController(userRepository: userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MoodController(emotionRepository: emotionRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MentalMood',
        theme: AppTheme.theme,
        themeMode: ThemeMode.dark,
        locale: const Locale('en', 'GB'),
        supportedLocales: const [Locale('en', 'GB')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: loggedIn ? '/home' : '/login',
        onGenerateRoute: (settings) {
          final page = switch (settings.name) {
            '/login' => const LoginPage(),
            '/register' => const RegisterPage(),
            '/home' => const MainNavigationContainer(),
            _ => const LoginPage(),
          };
          return AppNavigator.route(page);
        },
      ),
    ),
  );
}
