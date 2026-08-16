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
import 'package:application/data/secure/secure_key_store.dart';
import 'package:application/domain/services/crypto_service.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/services/ai_api_client.dart';
import 'package:application/services/ai_controller.dart';
import 'package:application/services/checkin_scheduler.dart';
import 'package:application/services/sync_http_client.dart';
import 'package:application/services/sync_service.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:application/state/mood_controller.dart';
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

  final crypto = CryptoService();
  final keyStore = FlutterSecureKeyStore();
  final cloudController = CloudController(
    apiClient: AuthApiClient(),
    keyStore: keyStore,
    crypto: crypto,
    userRepository: userRepository,
    authController: authController,
  );
  final bool loggedIn = await cloudController.restoreSession();

  final syncService = SyncService(
    emotionRepository: emotionRepository,
    httpClient: HttpSyncClient(),
    crypto: crypto,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: userRepository),
        Provider<EmotionRepository>.value(value: emotionRepository),
        Provider<SecureKeyStore>.value(value: keyStore),
        Provider<CryptoService>.value(value: crypto),
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider<CloudController>.value(
          value: cloudController,
        ),
        ChangeNotifierProvider<SyncService>.value(value: syncService),
        ChangeNotifierProvider(
          create: (_) => AiController(apiClient: HttpAiApiClient()),
        ),
        ChangeNotifierProvider(
          create: (_) => MoodController(emotionRepository: emotionRepository),
        ),
        Provider<CheckinScheduler>.value(
          value: CheckinScheduler(
            notifications: _UnimplementedNotificationService(),
            now: DateTime.now,
          ),
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

/// Placeholder finché l'implementazione nativa delle notifiche non è
/// disponibile (richiede la config nativa Android/iOS, documentata al deploy).
class _UnimplementedNotificationService implements NotificationService {
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
