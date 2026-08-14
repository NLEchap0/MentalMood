import 'package:application/domain/services/crypto_service.dart';
import 'package:application/domain/services/encrypted_payload.dart';
import 'package:cryptography/cryptography.dart';
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

  group('CryptoService string encryption', () {
    test('encrypt/decrypt roundtrip', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final dek = await crypto.generateDek();

      final payload = await crypto.encryptString('nota segreta 123', dek);
      final plain = crypto.decryptString(payload, dek);

      expect(plain, 'nota segreta 123');
    });

    test('encryptString produces different ciphertext each time (random nonce)',
        () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final dek = await crypto.generateDek();

      final p1 = await crypto.encryptString('stesso testo', dek);
      final p2 = await crypto.encryptString('stesso testo', dek);

      expect(p1.cipherText, isNot(p2.cipherText));
      expect(p1.nonce, isNot(p2.nonce));
    });

    test('decryptString throws on tampered ciphertext', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final dek = await crypto.generateDek();
      final payload = await crypto.encryptString('dati intimi', dek);

      final tampered = EncryptedPayload(
        nonce: payload.nonce,
        cipherText: [...payload.cipherText]..[0] = payload.cipherText[0] ^ 0xFF,
        mac: payload.mac,
      );

      expect(
        () => crypto.decryptString(tampered, dek),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('decryptString with wrong key throws', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final dek = await crypto.generateDek();
      final wrongDek = await crypto.generateDek();
      final payload = await crypto.encryptString('segreto', dek);

      expect(
        () => crypto.decryptString(payload, wrongDek),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('serialized payload survives base64 roundtrip after decryption',
        () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final dek = await crypto.generateDek();

      final payload = await crypto.encryptString('giro completo', dek);
      final restored = EncryptedPayload.fromBytes(payload.toBytes());

      expect(crypto.decryptString(restored, dek), 'giro completo');
    });
  });

  group('CryptoService envelope (DEK wrapping)', () {
    test('wrapDek/unwrapDek roundtrip', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final salt = List<int>.generate(16, (i) => i);
      final kek = await crypto.deriveKek(password: 'password123', salt: salt);
      final dek = await crypto.generateDek();

      final wrapped = await crypto.wrapDek(dek: dek, kek: kek);
      final unwrapped = await crypto.unwrapDek(wrappedDek: wrapped, kek: kek);

      expect(await unwrapped.extractBytes(), await dek.extractBytes());
    });

    test('unwrapDek with wrong KEK fails', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final salt = List<int>.generate(16, (i) => i);
      final kek = await crypto.deriveKek(password: 'password123', salt: salt);
      final wrongKek = await crypto.deriveKek(password: 'wrongpass', salt: salt);
      final dek = await crypto.generateDek();

      final wrapped = await crypto.wrapDek(dek: dek, kek: kek);

      await expectLater(
        crypto.unwrapDek(wrappedDek: wrapped, kek: wrongKek),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('wrapped DEK starts with version byte and roundtrips through base64',
        () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final salt = List<int>.generate(16, (i) => i);
      final kek = await crypto.deriveKek(password: 'password123', salt: salt);
      final dek = await crypto.generateDek();

      final wrapped = await crypto.wrapDek(dek: dek, kek: kek);

      expect(wrapped.first, payloadVersion);
      final restored = EncryptedPayload.fromBytes(wrapped);
      final unwrapped = await crypto.unwrapDek(
        wrappedDek: EncryptedPayload(
          nonce: restored.nonce,
          cipherText: restored.cipherText,
          mac: restored.mac,
        ).toBytes(),
        kek: kek,
      );
      expect(await unwrapped.extractBytes(), await dek.extractBytes());
    });
  });
}
