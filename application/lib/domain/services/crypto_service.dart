import 'dart:math';
import 'dart:typed_data';

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
      secretKey: SecretKey(Uint8List.fromList(password.codeUnits)),
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

  SecretKey dekFromBytes(List<int> bytes) =>
      SecretKey(Uint8List.fromList(bytes));
}
