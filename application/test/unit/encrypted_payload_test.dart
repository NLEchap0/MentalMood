import 'dart:convert';

import 'package:application/domain/services/encrypted_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EncryptedPayload serialization', () {
    test('toBytes roundtrips through fromBytes', () {
      final payload = EncryptedPayload(
        nonce: List<int>.generate(12, (i) => i),
        cipherText: [1, 2, 3, 4, 5],
        mac: List<int>.generate(16, (i) => i + 100),
      );

      final restored = EncryptedPayload.fromBytes(payload.toBytes());

      expect(restored.nonce, payload.nonce);
      expect(restored.cipherText, payload.cipherText);
      expect(restored.mac, payload.mac);
    });

    test('toBytes starts with version byte 0x01', () {
      final payload = EncryptedPayload(
        nonce: List<int>.generate(12, (i) => i),
        cipherText: [1],
        mac: List<int>.generate(16, (i) => i),
      );

      expect(payload.toBytes().first, 0x01);
    });

    test('fromBytes rejects unknown version byte', () {
      final bytes = <int>[0x02, ...List<int>.generate(12, (i) => i), 1, 2, 3];

      expect(
        () => EncryptedPayload.fromBytes(bytes),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromBytes rejects malformed input (too short)', () {
      expect(
        () => EncryptedPayload.fromBytes([0x01, 1, 2]),
        throwsA(isA<FormatException>()),
      );
    });

    test('base64 helpers roundtrip', () {
      final payload = EncryptedPayload(
        nonce: List<int>.generate(12, (i) => i),
        cipherText: [9, 9, 9],
        mac: List<int>.generate(16, (i) => i + 7),
      );

      final b64 = base64Encode(payload.toBytes());
      final restored = EncryptedPayload.fromBytes(base64Decode(b64));

      expect(restored.cipherText, payload.cipherText);
      expect(restored.mac, payload.mac);
    });
  });
}
