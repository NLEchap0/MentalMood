import 'dart:convert';

import 'package:application/data/sync/sync_models.dart';
import 'package:application/services/sync_http_client.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

class MockSyncHttpClient extends Mock implements SyncHttpClient {}

void main() {
  group('HttpSyncClient', () {
    test('sends signed body with bearer and hmac headers', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response('{"pulled":[],"server_time":"2026-01-01T12:00:00Z"}', 200);
      });

      final sync = HttpSyncClient(client: client);
      final body = {
        'ts': 1000,
        'nonce': 'a' * 32,
        'records': <Map<String, dynamic>>[],
      };
      final result = await sync.postSync(
        baseUrl: 'http://test.local',
        accessToken: 'token123',
        syncKey: 'k' * 64,
        body: body,
      );

      expect(captured.url.toString(), 'http://test.local/sync');
      expect(captured.headers['Authorization'], 'Bearer token123');
      expect(captured.headers['Content-Type'], 'application/json');
      final sig = captured.headers['X-Sync-Signature'];
      expect(sig, isNotNull);
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(sig!), isTrue);
      expect(jsonDecode(captured.body)['ts'], 1000);
      expect(result['pulled'], isEmpty);
    });

    test('signature is HMAC-SHA256 hex matching RFC 4231 vector', () async {
      final hmac = Hmac.sha256();
      final key = SecretKey(utf8.encode('key'));
      final data = utf8.encode('The quick brown fox jumps over the lazy dog');
      final mac = await hmac.calculateMac(data, secretKey: key);
      final vectorHex = mac.bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      expect(
        vectorHex,
        'f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8',
      );

      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response('{"pulled":[],"server_time":"2026-01-01T12:00:00Z"}', 200);
      });
      final sync = HttpSyncClient(client: client);
      final body = {
        'ts': 1000,
        'nonce': 'a' * 32,
        'records': <Map<String, dynamic>>[],
      };
      await sync.postSync(
        baseUrl: 'http://test.local',
        accessToken: 'token123',
        syncKey: 'key',
        body: body,
      );

      final expected = await hmac.calculateMac(
        utf8.encode(jsonEncode(body)),
        secretKey: key,
      );
      final expectedHex = expected.bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      expect(captured.headers['X-Sync-Signature'], expectedHex);
    });

    test('throws SyncFailure 402 on payment required', () async {
      final client = MockClient((_) async {
        return http.Response(
          '{"error":{"code":"payment_required","message":"payment_required"}}',
          402,
        );
      });
      final sync = HttpSyncClient(client: client);
      expect(
        () => sync.postSync(
          baseUrl: 'http://test.local',
          accessToken: 't',
          syncKey: 'k' * 64,
          body: {'ts': 1, 'nonce': 'a' * 32, 'records': []},
        ),
        throwsA(isA<SyncFailure>()
            .having((e) => e.statusCode, 'statusCode', 402)
            .having((e) => e.code, 'code', 'payment_required')),
      );
    });

    test('throws SyncFailure network on socket error', () async {
      final client = MockClient((_) async => throw Exception('boom'));
      final sync = HttpSyncClient(client: client);
      expect(
        () => sync.postSync(
          baseUrl: 'http://test.local',
          accessToken: 't',
          syncKey: 'k' * 64,
          body: {'ts': 1, 'nonce': 'a' * 32, 'records': []},
        ),
        throwsA(isA<SyncFailure>()
            .having((e) => e.statusCode, 'statusCode', 0)
            .having((e) => e.code, 'code', 'network_error')),
      );
    });
  });
}
