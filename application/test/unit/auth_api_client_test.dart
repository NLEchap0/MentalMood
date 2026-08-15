import 'dart:convert';

import 'package:application/services/auth_api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await dotenv.load(fileName: '.env');
  });

  group('AuthApiClient', () {
    test('login returns AuthSession with tokens and sync key', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/login');
        return http.Response(
          jsonEncode({
            'access_token': 'at',
            'refresh_token': 'rt',
            'sync_key': 'k' * 64,
            'expires_in': 900,
            'user': {
              'username': 'mario',
              'plan': 'free',
              'trial_ends_at': '2026-08-28T00:00:00Z',
            },
          }),
          200,
        );
      });
      final api = AuthApiClient(client: client);
      final session = await api.login(username: 'mario', password: 'pw');
      expect(session.accessToken, 'at');
      expect(session.refreshToken, 'rt');
      expect(session.syncKey.length, 64);
      expect(session.username, 'mario');
      expect(session.plan, 'free');
      expect(session.trialEndsAt, isNotNull);
    });

    test('login maps 401 to CloudApiFailure', () async {
      final client = MockClient((_) async => http.Response(
            '{"error":{"code":"auth_error","message":"invalid_credentials"}}',
            401,
          ));
      final api = AuthApiClient(client: client);
      await expectLater(
        api.login(username: 'm', password: 'x'),
        throwsA(isA<CloudApiFailure>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.code, 'code', 'auth_error')),
      );
    });

    test('register sends kek_salt and wrapped_dek', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response('{"id":1,"username":"mario"}', 201);
      });
      final api = AuthApiClient(client: client);
      await api.register(
        username: 'mario',
        password: 'pw',
        kekSalt: 'a' * 32,
        wrappedDek: 'b64',
      );
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['kek_salt'], 'a' * 32);
      expect(body['wrapped_dek'], 'b64');
    });

    test('subscription parses info', () async {
      final client = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer at');
        return http.Response(
          jsonEncode({
            'plan': 'pro',
            'status': 'active',
            'trial_ends_at': null,
            'current_period_end': '2026-09-01T00:00:00Z',
            'ai_credits': 12,
          }),
          200,
        );
      });
      final api = AuthApiClient(client: client);
      final info = await api.subscription('at');
      expect(info.plan, 'pro');
      expect(info.status, 'active');
      expect(info.aiCredits, 12);
    });

    test('setConsent posts and parses result', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/consent');
        return http.Response('{"consent":true,"deleted":0}', 200);
      });
      final api = AuthApiClient(client: client);
      final result = await api.setConsent(accessToken: 'at', consent: true);
      expect(result.consent, true);
      expect(result.deleted, 0);
    });

    test('exportData returns map', () async {
      final client = MockClient((_) async => http.Response(
            '{"username":"mario","emotions":[]}',
            200,
          ));
      final api = AuthApiClient(client: client);
      final data = await api.exportData('at');
      expect(data['username'], 'mario');
    });

    test('deleteAccount sends DELETE and maps error', () async {
      var called = false;
      final client = MockClient((request) async {
        called = true;
        expect(request.method, 'DELETE');
        expect(request.url.path, '/account');
        return http.Response('{"deleted":true,"stripe_cancelled":false}', 200);
      });
      final api = AuthApiClient(client: client);
      await api.deleteAccount('at');
      expect(called, true);
    });

    test('network errors map to CloudApiFailure 0/network_error', () async {
      final client = MockClient((_) async => throw Exception('boom'));
      final api = AuthApiClient(client: client);
      await expectLater(
        api.login(username: 'm', password: 'x'),
        throwsA(isA<CloudApiFailure>()
            .having((e) => e.statusCode, 'statusCode', 0)
            .having((e) => e.code, 'code', 'network_error')),
      );
    });
  });
}
