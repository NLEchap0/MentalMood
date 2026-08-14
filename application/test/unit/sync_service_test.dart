import 'dart:convert';

import 'package:application/data/repositories/emotion_repository.dart';
import 'package:application/data/sync/sync_models.dart';
import 'package:application/domain/models.dart';
import 'package:application/domain/services/crypto_service.dart';
import 'package:application/domain/services/encrypted_payload.dart';
import 'package:application/services/sync_http_client.dart';
import 'package:application/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockEmotionRepository extends Mock implements EmotionRepository {}

class MockSyncHttpClient extends Mock implements SyncHttpClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockEmotionRepository repo;
  late MockSyncHttpClient httpClient;
  late CryptoService crypto;
  late SyncService service;
  var clock = DateTime.utc(2026, 1, 1, 12);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = MockEmotionRepository();
    httpClient = MockSyncHttpClient();
    crypto = CryptoService(pbkdf2Iterations: 1000);
    service = SyncService(
      emotionRepository: repo,
      httpClient: httpClient,
      crypto: crypto,
      now: () => clock,
    );
  });

  group('SyncService sync', () {
    test('sends encrypted payload and advances since cursor', () async {
      final dek = await crypto.generateDek();
      when(() => repo.getEmotionsForUser(1)).thenAnswer((_) async => [
        MoodEntry(
          id: 7,
          value: 8,
          userId: 1,
          createdAt: DateTime.utc(2026, 1, 1, 8),
          note: 'great day',
          tags: ['work'],
        ),
      ]);
      when(() => httpClient.postSync(
        baseUrl: any(named: 'baseUrl'),
        accessToken: any(named: 'accessToken'),
        syncKey: any(named: 'syncKey'),
        body: any(named: 'body'),
      )).thenAnswer((inv) async {
        final body = inv.namedArguments[#body] as Map<String, dynamic>;
        final records = body['records'] as List<dynamic>;
        expect(records.length, 1);
        final rec = records.first as Map<String, dynamic>;
        expect(rec['record_key'], 'emotion:7');
        expect(rec['entity'], 'emotion');
        expect(rec['deleted'], false);
        final payload = base64Decode(rec['payload'] as String);
        final restored = EncryptedPayload.fromBytes(payload);
        final plain = crypto.decryptString(restored, dek);
        final parsed = jsonDecode(plain) as Map<String, dynamic>;
        expect(parsed['value'], 8);
        expect(parsed['note'], 'great day');
        return {'pulled': <dynamic>[], 'server_time': '2026-01-01T12:00:00Z'};
      });

      final ok = await service.sync(
        userId: 1,
        credentials: SyncCredentials(
          accessToken: 't',
          syncKey: 'k' * 64,
          dek: dek,
        ),
      );

      expect(ok, true);
      expect(service.state, SyncState.success);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('sync_since_1'), '2026-01-01T12:00:00.000Z');
    });

    test('skips entries older than since', () async {
      final dek = await crypto.generateDek();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sync_since_1', '2026-01-01T10:00:00.000Z');
      when(() => repo.getEmotionsForUser(1)).thenAnswer((_) async => [
        MoodEntry(
          id: 5,
          value: 3,
          userId: 1,
          createdAt: DateTime.utc(2026, 1, 1, 8),
        ),
      ]);
      when(() => httpClient.postSync(
        baseUrl: any(named: 'baseUrl'),
        accessToken: any(named: 'accessToken'),
        syncKey: any(named: 'syncKey'),
        body: any(named: 'body'),
      )).thenAnswer((inv) async {
        final body = inv.namedArguments[#body] as Map<String, dynamic>;
        expect((body['records'] as List<dynamic>), isEmpty);
        return {'pulled': <dynamic>[], 'server_time': '2026-01-01T12:00:00Z'};
      });

      await service.sync(
        userId: 1,
        credentials: SyncCredentials(accessToken: 't', syncKey: 'k' * 64, dek: dek),
      );
    });

    test('maps 402 to paymentRequired state', () async {
      final dek = await crypto.generateDek();
      when(() => repo.getEmotionsForUser(1)).thenAnswer((_) async => []);
      when(() => httpClient.postSync(
        baseUrl: any(named: 'baseUrl'),
        accessToken: any(named: 'accessToken'),
        syncKey: any(named: 'syncKey'),
        body: any(named: 'body'),
      )).thenThrow(const SyncFailure(
        statusCode: 402,
        code: 'payment_required',
        message: 'payment_required',
      ));

      final ok = await service.sync(
        userId: 1,
        credentials: SyncCredentials(accessToken: 't', syncKey: 'k' * 64, dek: dek),
      );

      expect(ok, false);
      expect(service.state, SyncState.paymentRequired);
    });

    test('applies pulled records and tombstones', () async {
      final dek = await crypto.generateDek();
      when(() => repo.getEmotionsForUser(1)).thenAnswer((_) async => []);
      final pulledPayload = base64Encode(
        (await crypto.encryptString(
          jsonEncode({
            'value': 6,
            'note': 'from server',
            'tags': <String>[],
            'createdAt': '2026-01-01T09:00:00.000Z',
          }),
          dek,
        ))
            .toBytes(),
      );
      when(() => httpClient.postSync(
        baseUrl: any(named: 'baseUrl'),
        accessToken: any(named: 'accessToken'),
        syncKey: any(named: 'syncKey'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => {
        'pulled': [
          {
            'record_key': 'emotion:99',
            'entity': 'emotion',
            'payload': pulledPayload,
            'updated_at': '2026-01-01T09:00:00Z',
            'deleted': 0,
          },
          {
            'record_key': 'emotion:7',
            'entity': 'emotion',
            'payload': null,
            'updated_at': '2026-01-01T11:00:00Z',
            'deleted': 1,
          },
        ],
        'server_time': '2026-01-01T12:00:00Z',
      });
      when(() => repo.addEmotion(
        userId: any(named: 'userId'),
        value: any(named: 'value'),
        note: any(named: 'note'),
        tags: any(named: 'tags'),
        createdAt: any(named: 'createdAt'),
      )).thenAnswer((_) async => 99);
      when(() => repo.deleteEmotion(7)).thenAnswer((_) async {});

      final ok = await service.sync(
        userId: 1,
        credentials: SyncCredentials(accessToken: 't', syncKey: 'k' * 64, dek: dek),
      );

      expect(ok, true);
      verify(() => repo.addEmotion(
        userId: 1,
        value: 6,
        note: 'from server',
        tags: any(named: 'tags', that: isEmpty),
        createdAt: DateTime.utc(2026, 1, 1, 9),
      )).called(1);
      verify(() => repo.deleteEmotion(7)).called(1);
    });
  });
}
