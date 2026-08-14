import 'package:application/domain/services/crypto_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CryptoService key derivation', () {
    test('deriveKek returns deterministic key for same password+salt', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final salt = List<int>.generate(16, (i) => i);

      final k1 = await crypto.deriveKek(password: 'password123', salt: salt);
      final k2 = await crypto.deriveKek(password: 'password123', salt: salt);

      expect(await k1.extractBytes(), await k2.extractBytes());
      expect((await k1.extractBytes()).length, 32);
    });

    test('deriveKek returns different key for different password', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final salt = List<int>.generate(16, (i) => i);

      final k1 = await crypto.deriveKek(password: 'password123', salt: salt);
      final k2 = await crypto.deriveKek(password: 'password456', salt: salt);

      expect(await k1.extractBytes(), isNot(await k2.extractBytes()));
    });

    test('deriveKek returns different key for different salt', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final salt1 = List<int>.generate(16, (i) => i);
      final salt2 = List<int>.generate(16, (i) => i + 1);

      final k1 = await crypto.deriveKek(password: 'password123', salt: salt1);
      final k2 = await crypto.deriveKek(password: 'password123', salt: salt2);

      expect(await k1.extractBytes(), isNot(await k2.extractBytes()));
    });

    test('generateDek returns 32 random bytes', () async {
      final crypto = CryptoService();
      final d1 = await crypto.generateDek();
      final d2 = await crypto.generateDek();

      expect((await d1.extractBytes()).length, 32);
      expect(await d1.extractBytes(), isNot(await d2.extractBytes()));
    });

    test('generateSalt returns 32 hex chars (16 bytes)', () async {
      final crypto = CryptoService();
      final salt = await crypto.generateSalt();

      expect(salt.length, 32);
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(salt), isTrue);
    });

    test('dekFromBytes roundtrips', () async {
      final crypto = CryptoService();
      final bytes = List<int>.generate(32, (i) => i);

      expect(await crypto.dekFromBytes(bytes).extractBytes(), bytes);
    });
  });
}
