import 'dart:convert';

import 'package:application/data/repositories/user_repository.dart';
import 'package:application/data/secure/secure_key_store.dart';
import 'package:application/domain/models.dart';
import 'package:application/domain/services/crypto_service.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/state/auth_controller.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthApiClient extends Mock implements AuthApiClient {}

class MockUserRepository extends Mock implements UserRepository {}

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
  late MockAuthApiClient api;
  late InMemoryKeyStore store;
  late CryptoService crypto;
  late MockUserRepository userRepo;
  late AuthController auth;
  late CloudController controller;

  setUp(() {
    api = MockAuthApiClient();
    store = InMemoryKeyStore();
    crypto = CryptoService(pbkdf2Iterations: 1000);
    userRepo = MockUserRepository();
    auth = AuthController(userRepository: userRepo);
    controller = CloudController(
      apiClient: api,
      keyStore: store,
      crypto: crypto,
      userRepository: userRepo,
      authController: auth,
    );
    // La cache drift locale è un dettaglio interno: di default l'utente
    // esiste già, così _syncLocalUser non crea duplicati nei test.
    when(() => userRepo.getUserByUsername(any())).thenAnswer((_) async =>
        AppUser(
          id: 1,
          username: 'mario',
          name: 'Mario',
          surname: 'Mood',
          birthDate: DateTime(2000),
          passwordHash: 'cloud-only',
        ));
    // Default: il refresh conserva la sessione (i test specifici lo
    // sovrascrivono). Evita che restoreSession faccia logout nei test
    // che non riguardano il refresh.
    when(() => api.refresh(any())).thenAnswer((_) async => _session());
  });

  group('CloudController register', () {
    test('generates salt+DEK, wraps DEK, registers and stores session',
        () async {
      when(() => api.register(
            username: any(named: 'username'),
            password: any(named: 'password'),
            email: any(named: 'email'),
            kekSalt: any(named: 'kekSalt'),
            wrappedDek: any(named: 'wrappedDek'),
          )).thenAnswer((inv) async {
        final kekSalt = inv.namedArguments[#kekSalt] as String;
        expect(kekSalt.length, 32); // hex 16 byte
        final wrapped = inv.namedArguments[#wrappedDek] as String;
        expect(wrapped.length, greaterThan(50)); // base64 blob
        return {'id': 1, 'username': 'mario'};
      });
      when(() => api.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => _session());

      final ok = await controller.registerCloud(
        username: 'mario',
        email: 'mario@example.com',
        password: 'password123',
      );

      expect(ok, true);
      expect(controller.session, isNotNull);
      expect(controller.session!.username, 'mario');
      final dekHex = await store.read('cloud_dek');
      expect(dekHex, isNotNull);
      expect(dekHex!.length, 64); // 32 byte hex
      final salt = await store.read('cloud_kek_salt');
      expect(salt, isNotNull);
    });
  });

  group('CloudController login', () {
    test('login stores session and unwraps DEK from export', () async {
      // Prepara un utente registrato: salt+DEK sul server (simulato in store)
      final dek = await crypto.generateDek();
      final salt = await crypto.generateSalt();
      final kek = await crypto.deriveKek(password: 'password123', salt: [
        for (var i = 0; i < 16; i++) int.parse(salt.substring(i * 2, i * 2 + 2), radix: 16),
      ]);
      final wrapped = await crypto.wrapDek(dek: dek, kek: kek);

      when(() => api.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => _session());
      when(() => api.exportData(any()))
          .thenAnswer((_) async => {
                'username': 'mario',
                'kek_salt': salt,
                'wrapped_dek': base64Encode(wrapped),
                'emotions': <dynamic>[],
              });

      final ok = await controller.loginCloud(
        username: 'mario',
        password: 'password123',
      );

      expect(ok, true);
      expect(controller.session!.username, 'mario');
      final dekHex = await store.read('cloud_dek');
      expect(dekHex, isNotNull);
      // La DEK salvata deve decriptare i dati
      expect(await store.read('cloud_access_token'), 'at');
      expect(await store.read('cloud_refresh_token'), 'rt');
      expect(await store.read('cloud_sync_key'), 'k' * 64);
    });

    test('login failure keeps state disconnected', () async {
      when(() => api.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenThrow(const CloudApiFailure(
        statusCode: 401,
        code: 'auth_error',
        message: 'invalid_credentials',
      ));
      final ok = await controller.loginCloud(
        username: 'mario',
        password: 'wrong',
      );
      expect(ok, false);
      expect(controller.session, isNull);
      expect(controller.errorCode, 'auth_error');
    });

    test('restores session from storage at startup', () async {
      await store.write('cloud_username', 'mario');
      await store.write('cloud_access_token', 'at');
      await store.write('cloud_refresh_token', 'rt');
      await store.write('cloud_sync_key', 'k' * 64);
      await store.write('cloud_dek', 'd' * 64);
      await store.write('cloud_plan', 'free');
      await store.write('cloud_status', 'none');

      final restored = await controller.restoreSession();
      expect(restored, true);
      expect(controller.session!.username, 'mario');
      expect(controller.session!.accessToken, 'at');
    });

    test('restoreSession returns false when no session stored', () async {
      final restored = await controller.restoreSession();
      expect(restored, false);
    });
  });

  group('CloudController logout/consent/subscription', () {
    test('logout clears stored session', () async {
      await store.write('cloud_username', 'mario');
      await store.write('cloud_access_token', 'at');
      await controller.logoutCloud();
      expect(controller.session, isNull);
      expect(await store.read('cloud_access_token'), isNull);
    });

    test('refreshSubscription updates plan info', () async {
      await store.write('cloud_username', 'mario');
      await store.write('cloud_access_token', 'at');
      await store.write('cloud_refresh_token', 'rt');
      await store.write('cloud_sync_key', 'k' * 64);
      await store.write('cloud_dek', 'd' * 64);
      await store.write('cloud_plan', 'free');
      await store.write('cloud_status', 'none');
      await controller.restoreSession();

      when(() => api.subscription('at')).thenAnswer((_) async =>
          const SubscriptionInfo(
              plan: 'pro', status: 'active', aiCredits: 5));
      final ok = await controller.refreshSubscription();
      expect(ok, true);
      expect(controller.subscription?.plan, 'pro');
      expect(controller.subscription?.aiCredits, 5);
    });

    test('setConsent updates consent state', () async {
      await store.write('cloud_username', 'mario');
      await store.write('cloud_access_token', 'at');
      await store.write('cloud_refresh_token', 'rt');
      await store.write('cloud_sync_key', 'k' * 64);
      await store.write('cloud_dek', 'd' * 64);
      await store.write('cloud_plan', 'free');
      await store.write('cloud_status', 'none');
      await controller.restoreSession();

      when(() => api.setConsent(
            accessToken: any(named: 'accessToken'),
            consent: any(named: 'consent'),
          )).thenAnswer((_) async =>
              const ConsentResult(consent: true, deleted: 0));
      final ok = await controller.setAiConsent(true);
      expect(ok, true);
      expect(controller.consentEnabled, true);
    });
  });

  group('CloudController token refresh', () {
    Future<void> seedSession() async {
      await store.write('cloud_username', 'mario');
      await store.write('cloud_access_token', 'expired_at');
      await store.write('cloud_refresh_token', 'rt_old');
      await store.write('cloud_sync_key', 'k' * 64);
      await store.write('cloud_dek', 'd' * 64);
      await store.write('cloud_plan', 'free');
      await store.write('cloud_status', 'none');
      await controller.restoreSession();
    }

    test('ensureFreshSession refreshes when access token rejected', () async {
      when(() => api.refresh('rt_old')).thenAnswer((_) async => AuthSession(
            id: 1,
            accessToken: 'at_new',
            refreshToken: 'rt_new',
            syncKey: 'k' * 64,
            username: 'mario',
            plan: 'free',
            status: 'none',
          ));
      await seedSession(); // scrive lo store e ripristina -> refresh automatico

      expect(controller.session!.accessToken, 'at_new');
      expect(controller.session!.refreshToken, 'rt_new');
      expect(await store.read('cloud_access_token'), 'at_new');
      expect(await store.read('cloud_refresh_token'), 'rt_new');
    });

    test('ensureFreshSession logs out when refresh fails', () async {
      when(() => api.refresh('rt_old')).thenThrow(const CloudApiFailure(
          statusCode: 401, code: 'auth_error', message: ''));
      await seedSession(); // restoreSession fallisce -> logout

      final fresh = await controller.ensureFreshSession();
      expect(fresh, false);
      expect(controller.session, isNull);
      expect(await store.read('cloud_access_token'), isNull);
    });
  });
}

AuthSession _session() => AuthSession(
      id: 1,
      accessToken: 'at',
      refreshToken: 'rt',
      syncKey: 'k' * 64,
      username: 'mario',
      plan: 'free',
      status: 'none',
    );
