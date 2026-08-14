import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:application/domain/services/encrypted_payload.dart';
import 'package:cryptography/cryptography.dart';

/// E2EE envelope cryptography: KEK derived from password (PBKDF2),
/// random 32-byte DEK for bulk data, AES-256-GCM for records.
class CryptoService {
  CryptoService({this.pbkdf2Iterations = 600000});

  final int pbkdf2Iterations;

  static final _aesGcm = AesGcm.with256bits();
  static final _random = Random.secure();

  Future<SecretKey> deriveKek({
    required String password,
    required List<int> salt,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: pbkdf2Iterations,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(Uint8List.fromList(utf8.encode(password))),
      nonce: salt,
    );
  }

  Future<SecretKey> generateDek() async {
    final bytes = Uint8List.fromList(
      List<int>.generate(32, (_) => _random.nextInt(256)),
    );
    return SecretKey(bytes);
  }

  Future<String> generateSalt() async {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  SecretKey dekFromBytes(List<int> bytes) {
    if (bytes.length != 32) {
      throw ArgumentError('DEK must be exactly 32 bytes, got ${bytes.length}');
    }
    return SecretKey(Uint8List.fromList(bytes));
  }

  Future<EncryptedPayload> encryptString(
    String plaintext,
    SecretKey dek,
  ) async {
    final nonce = Uint8List.fromList(
      List<int>.generate(nonceLength, (_) => _random.nextInt(256)),
    );
    final box = await _aesGcm.encrypt(
      Uint8List.fromList(utf8.encode(plaintext)),
      secretKey: dek,
      nonce: nonce,
    );
    return EncryptedPayload(
      nonce: box.nonce,
      cipherText: box.cipherText,
      mac: box.mac.bytes,
    );
  }

  Future<List<int>> wrapDek({
    required SecretKey dek,
    required SecretKey kek,
  }) async {
    final nonce = Uint8List.fromList(
      List<int>.generate(nonceLength, (_) => _random.nextInt(256)),
    );
    final box = await _aesGcm.encrypt(
      await dek.extractBytes(),
      secretKey: kek,
      nonce: nonce,
    );
    return EncryptedPayload(
      nonce: box.nonce,
      cipherText: box.cipherText,
      mac: box.mac.bytes,
    ).toBytes();
  }

  Future<SecretKey> unwrapDek({
    required List<int> wrappedDek,
    required SecretKey kek,
  }) async {
    final payload = EncryptedPayload.fromBytes(wrappedDek);
    final box = SecretBox(
      payload.cipherText,
      nonce: payload.nonce,
      mac: Mac(payload.mac),
    );
    final dekBytes = await _aesGcm.decrypt(box, secretKey: kek);
    return SecretKey(dekBytes);
  }

  String decryptString(EncryptedPayload payload, SecretKey dek) {
    if (dek is! SecretKeyData) {
      throw ArgumentError('decryptString requires an in-memory SecretKeyData');
    }
    final box = SecretBox(
      payload.cipherText,
      nonce: payload.nonce,
      mac: Mac(payload.mac),
    );
    final decrypted = _aesGcm.toSync().decryptSync(
          box,
          secretKeyData: dek,
        );
    return utf8.decode(decrypted);
  }
}
