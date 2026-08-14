import 'package:application/data/sync/sync_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncRecord', () {
    test('toJson serializes all fields', () {
      final r = SyncRecord(
        recordKey: 'emotion:1',
        entity: 'emotion',
        payload: 'dGVzdA==',
        updatedAt: DateTime.utc(2026, 1, 1, 10),
        deleted: false,
      );
      final json = r.toJson();
      expect(json['record_key'], 'emotion:1');
      expect(json['entity'], 'emotion');
      expect(json['payload'], 'dGVzdA==');
      expect(json['updated_at'], '2026-01-01T10:00:00.000Z');
      expect(json['deleted'], false);
    });

    test('fromJson parses a pull record', () {
      final r = SyncRecord.fromJson({
        'record_key': 'emotion:2',
        'entity': 'emotion',
        'payload': 'abc',
        'updated_at': '2026-01-01T10:05:00Z',
        'deleted': 1,
      });
      expect(r.recordKey, 'emotion:2');
      expect(r.deleted, true);
      expect(r.payload, 'abc');
    });
  });

  group('SyncPullResponse', () {
    test('fromJson parses pulled list and server_time', () {
      final resp = SyncPullResponse.fromJson({
        'pulled': [
          {'record_key': 'emotion:1', 'entity': 'emotion', 'payload': null, 'updated_at': '2026-01-01T10:00:00Z', 'deleted': 0},
        ],
        'server_time': '2026-01-01T12:00:00Z',
      });
      expect(resp.pulled.length, 1);
      expect(resp.serverTime.isUtc, true);
    });
  });

  group('SyncFailure', () {
    test('carries status code and code', () {
      final e = SyncFailure(statusCode: 402, code: 'payment_required', message: 'payment_required');
      expect(e.statusCode, 402);
      expect(e.code, 'payment_required');
    });
  });
}
