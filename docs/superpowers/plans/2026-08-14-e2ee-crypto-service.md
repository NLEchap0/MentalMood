# Fase 1 — Servizio Crittografia E2EE (Flutter) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Costruire il servizio di crittografia end-to-end (envelope encryption con AES-256-GCM e PBKDF2) nel progetto Flutter, con test completi.

**Architecture:** Servizio puro Dart (`CryptoService`) senza dipendenze Flutter — riceve password e salt e produce chiavi/record criptati. Un'astrazione `SecureKeyStore` isola `flutter_secure_storage` dietro un'interfaccia testabile. I payload criptati sono serializzabili (concatenazione nonce‖ciphertext‖mac + version byte).

**Tech Stack:** `cryptography` ^2.7.0 (puro Dart), `flutter_secure_storage` ^9.2.2, flutter_test, mocktail (già presente).

**Spec:** `docs/superpowers/specs/2026-08-14-mentalmood-cloud-ai-premium-design.md` — sezione "Crittografia E2EE".

## Global Constraints

- Progetto Flutter: `C:\Flutter\MentalMood\application` — tutti i comandi flutter girano con workdir su questa cartella.
- Codice in `lib/domain/services/` (puro Dart) e `lib/data/secure/` (storage).
- Test in `test/unit/` seguendo le convenzioni esistenti (mocktail, gruppi descrittivi).
- PBKDF2 default 600.000 iterazioni; **iniettabile** via costruttore (i test usano 1000).
- Zero segreti nei test e nel codice; niente commenti superflui.
- Push al termine della fase (commit per task).
- La cartella `API/` non esiste ancora; la Fase 1 tocca solo l'app.

---

### Task 1: Dipendenze + CryptoService con derivazione KEK e generazione DEK

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/domain/services/crypto_service.dart`
- Test: `test/unit/crypto_service_test.dart`

**Interfaces:**
- Consumes: nulla (primo task della fase).
- Produces: `CryptoService` con:
  - `CryptoService({int pbkdf2Iterations = 600000})`
  - `Future<SecretKey> deriveKek({required String password, required List<int> salt})` — PBKDF2-HMAC-SHA256, 32 byte.
  - `Future<SecretKey> generateDek()` — 32 byte casuali.
  - `Future<String> generateSalt()` — 16 byte casuali, hex.
  - `SecretKey dekFromBytes(List<int> bytes)` — helper per ricostruire la DEK dai byte.

- [ ] **Step 1: Aggiungi le dipendenze**

Run: `flutter pub add cryptography:flutter_secure_storage`
Expected: entrambe aggiunte a `dependencies` in pubspec.yaml senza errori.

- [ ] **Step 2: Scrivi il test fallito**

`test/unit/crypto_service_test.dart`:

```dart
import 'package:application/domain/services/crypto_service.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CryptoService key derivation', () {
    test('deriveKek returns deterministic key for same password+salt', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final salt = List<int>.generate(16, (i) => i);

      final k1 = await crypto.deriveKek(password: 'password123', salt: salt);
      final k2 = await crypto.deriveKek(password: 'password123', salt: salt);

      expect(k1.extractBytes(), k2.extractBytes());
      expect(k1.extractBytes().length, 32);
    });

    test('deriveKek returns different key for different password', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final salt = List<int>.generate(16, (i) => i);

      final k1 = await crypto.deriveKek(password: 'password123', salt: salt);
      final k2 = await crypto.deriveKek(password: 'password456', salt: salt);

      expect(k1.extractBytes(), isNot(k2.extractBytes()));
    });

    test('deriveKek returns different key for different salt', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final salt1 = List<int>.generate(16, (i) => i);
      final salt2 = List<int>.generate(16, (i) => i + 1);

      final k1 = await crypto.deriveKek(password: 'password123', salt: salt1);
      final k2 = await crypto.deriveKek(password: 'password123', salt: salt2);

      expect(k1.extractBytes(), isNot(k2.extractBytes()));
    });

    test('generateDek returns 32 random bytes', () async {
      final crypto = CryptoService();
      final d1 = await crypto.generateDek();
      final d2 = await crypto.generateDek();

      expect(d1.extractBytes().length, 32);
      expect(d1.extractBytes(), isNot(d2.extractBytes()));
    });

    test('generateSalt returns 32 hex chars (16 bytes)', () async {
      final crypto = CryptoService();
      final salt = await crypto.generateSalt();

      expect(salt.length, 32);
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(salt), isTrue);
    });

    test('dekFromBytes roundtrips', () {
      final crypto = CryptoService();
      final bytes = List<int>.generate(32, (i) => i);

      expect(crypto.dekFromBytes(bytes).extractBytes(), bytes);
    });
  });
}
```

- [ ] **Step 3: Esegui il test per verificare che fallisca**

Run: `flutter test test/unit/crypto_service_test.dart`
Expected: FAIL — "Target of URI doesn't exist" (file `crypto_service.dart` mancante).

- [ ] **Step 4: Scrivi l'implementazione minima**

`lib/domain/services/crypto_service.dart`:

```dart
import 'dart:math';

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
```

- [ ] **Step 5: Esegui il test per verificare che passi**

Run: `flutter test test/unit/crypto_service_test.dart`
Expected: PASS (6 test).

- [ ] **Step 6: Commit**

```bash
git add application/pubspec.yaml application/pubspec.lock application/lib/domain/services/crypto_service.dart application/test/unit/crypto_service_test.dart
git commit -m "feat(crypto): CryptoService con derivazione KEK (PBKDF2) e generazione DEK"
```

---

### Task 2: EncryptedPayload serializzabile + encryptString/decryptString

**Files:**
- Create: `lib/domain/services/encrypted_payload.dart`
- Modify: `lib/domain/services/crypto_service.dart`
- Test: `test/unit/encrypted_payload_test.dart`, `test/unit/crypto_service_test.dart`

**Interfaces:**
- Consumes: `CryptoService` dalla Task 1.
- Produces: `EncryptedPayload`:
  - `EncryptedPayload({required List<int> nonce, required List<int> cipherText, required List<int> mac})`
  - `List<int> toBytes()` — concatenazione `nonce(12)‖cipherText‖mac(16)` con **version byte 0x01 in testa**.
  - `static EncryptedPayload fromBytes(List<int> bytes)` — parsing inverso, lancia `FormatException` su version byte non 0x01 o input malformato.
- Su `CryptoService`:
  - `Future<EncryptedPayload> encryptString(String plaintext, SecretKey dek)`
  - `String decryptString(EncryptedPayload payload, SecretKey dek)` — lancia `SecretBoxAuthenticationError` se manomesso.

- [ ] **Step 1: Scrivi il test fallito per EncryptedPayload**

`test/unit/encrypted_payload_test.dart`:

```dart
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
```

- [ ] **Step 2: Esegui il test per verificare che fallisca**

Run: `flutter test test/unit/encrypted_payload_test.dart`
Expected: FAIL — file `encrypted_payload.dart` mancante.

- [ ] **Step 3: Scrivi l'implementazione minima**

`lib/domain/services/encrypted_payload.dart`:

```dart
/// Version byte per il formato di serializzazione.
/// 0x01 = AES-256-GCM, nonce 12 byte, mac 16 byte.
const int payloadVersion = 0x01;
const int nonceLength = 12;
const int macLength = 16;

class EncryptedPayload {
  const EncryptedPayload({
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  final List<int> nonce;
  final List<int> cipherText;
  final List<int> mac;

  List<int> toBytes() {
    return [
      payloadVersion,
      ...nonce,
      ...cipherText,
      ...mac,
    ];
  }

  static EncryptedPayload fromBytes(List<int> bytes) {
    if (bytes.length < 1 + nonceLength + macLength) {
      throw const FormatException('Payload troppo corto');
    }
    if (bytes.first != payloadVersion) {
      throw FormatException('Version byte sconosciuto: ${bytes.first}');
    }
    final cipherLength = bytes.length - 1 - nonceLength - macLength;
    return EncryptedPayload(
      nonce: bytes.sublist(1, 1 + nonceLength),
      cipherText: bytes.sublist(1 + nonceLength, 1 + nonceLength + cipherLength),
      mac: bytes.sublist(bytes.length - macLength),
    );
  }
}
```

- [ ] **Step 4: Esegui il test per verificare che passi**

Run: `flutter test test/unit/encrypted_payload_test.dart`
Expected: PASS (5 test).

- [ ] **Step 5: Scrivi i test falliti per encryptString/decryptString**

Aggiungi a `test/unit/crypto_service_test.dart` (in fondo a `main()`):

```dart
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
```

Aggiorna l'import in testa a `crypto_service_test.dart`:

```dart
import 'package:application/domain/services/encrypted_payload.dart';
import 'package:cryptography/cryptography.dart';
```

- [ ] **Step 6: Esegui i test per verificare che falliscano**

Run: `flutter test test/unit/crypto_service_test.dart`
Expected: FAIL — `encryptString`/`decryptString` non definiti.

- [ ] **Step 7: Implementa encryptString/decryptString**

Aggiungi a `lib/domain/services/crypto_service.dart` (dentro la classe, prima della chiusura):

```dart
  Future<EncryptedPayload> encryptString(
    String plaintext,
    SecretKey dek,
  ) async {
    final nonce = Uint8List.fromList(
      List<int>.generate(nonceLength, (_) => _random.nextInt(256)),
    );
    final box = await _aesGcm.encrypt(
      Uint8List.fromList(plaintext.codeUnits),
      secretKey: dek,
      nonce: nonce,
    );
    return EncryptedPayload(
      nonce: box.nonce,
      cipherText: box.cipherText,
      mac: box.mac,
    );
  }

  String decryptString(EncryptedPayload payload, SecretKey dek) {
    final box = SecretBox(
      payload.cipherText,
      nonce: payload.nonce,
      mac: Mac(payload.mac),
    );
    final decrypted = _aesGcm.decryptSync(box, secretKey: dek);
    return String.fromCharCodes(decrypted);
  }
```

Aggiorna l'import in `crypto_service.dart`:

```dart
import 'package:application/domain/services/encrypted_payload.dart';
```

- [ ] **Step 8: Esegui i test per verificare che passino**

Run: `flutter test test/unit/crypto_service_test.dart`
Expected: PASS (6 + 5 = 11 test).

- [ ] **Step 9: Commit**

```bash
git add application/lib/domain/services/encrypted_payload.dart application/lib/domain/services/crypto_service.dart application/test/unit/encrypted_payload_test.dart application/test/unit/crypto_service_test.dart
git commit -m "feat(crypto): AES-256-GCM encryptString/decryptString con payload serializzabile"
```

---

### Task 3: Envelope — wrapDek/unwrapDek

**Files:**
- Modify: `lib/domain/services/crypto_service.dart`
- Modify: `test/unit/crypto_service_test.dart`

**Interfaces:**
- Consumes: `CryptoService` (Task 1-2).
- Produces su `CryptoService`:
  - `Future<List<int>> wrapDek({required SecretKey dek, required SecretKey kek})` — cifra i 32 byte della DEK con AES-256-GCM (nonce random) e restituisce `EncryptedPayload.toBytes()`.
  - `Future<SecretKey> unwrapDek({required List<int> wrappedDek, required SecretKey kek})` — decodifica e decifra; lancia `SecretBoxAuthenticationError` se la KEK è sbagliata o il blob è manomesso.

- [ ] **Step 1: Scrivi i test falliti**

Aggiungi a `test/unit/crypto_service_test.dart` (in fondo a `main()`):

```dart
  group('CryptoService envelope (DEK wrapping)', () {
    test('wrapDek/unwrapDek roundtrip', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final salt = List<int>.generate(16, (i) => i);
      final kek = await crypto.deriveKek(password: 'password123', salt: salt);
      final dek = await crypto.generateDek();

      final wrapped = await crypto.wrapDek(dek: dek, kek: kek);
      final unwrapped = await crypto.unwrapDek(wrappedDek: wrapped, kek: kek);

      expect(unwrapped.extractBytes(), dek.extractBytes());
    });

    test('unwrapDek with wrong KEK fails', () async {
      final crypto = CryptoService(pbkdf2Iterations: 1000);
      final salt = List<int>.generate(16, (i) => i);
      final kek = await crypto.deriveKek(password: 'password123', salt: salt);
      final wrongKek = await crypto.deriveKek(password: 'wrongpass', salt: salt);
      final dek = await crypto.generateDek();

      final wrapped = await crypto.wrapDek(dek: dek, kek: kek);

      expect(
        () async => await crypto.unwrapDek(wrappedDek: wrapped, kek: wrongKek),
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
      expect(unwrapped.extractBytes(), dek.extractBytes());
    });
  });
```

Aggiorna l'import: `encrypted_payload.dart` già presente dalla Task 2.

- [ ] **Step 2: Esegui i test per verificare che falliscano**

Run: `flutter test test/unit/crypto_service_test.dart`
Expected: FAIL — `wrapDek`/`unwrapDek` non definiti.

- [ ] **Step 3: Implementa wrapDek/unwrapDek**

Aggiungi a `lib/domain/services/crypto_service.dart` (dentro la classe):

```dart
  Future<List<int>> wrapDek({
    required SecretKey dek,
    required SecretKey kek,
  }) async {
    final nonce = Uint8List.fromList(
      List<int>.generate(nonceLength, (_) => _random.nextInt(256)),
    );
    final box = await _aesGcm.encrypt(dek.extractBytes(), secretKey: kek, nonce: nonce);
    return EncryptedPayload(
      nonce: box.nonce,
      cipherText: box.cipherText,
      mac: box.mac,
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
```

- [ ] **Step 4: Esegui i test per verificare che passino**

Run: `flutter test test/unit/crypto_service_test.dart`
Expected: PASS (11 + 3 = 14 test).

- [ ] **Step 5: Commit**

```bash
git add application/lib/domain/services/crypto_service.dart application/test/unit/crypto_service_test.dart
git commit -m "feat(crypto): envelope wrapDek/unwrapDek (KEK/DEK)"
```

---

### Task 4: SecureKeyStore (astrazione per flutter_secure_storage)

**Files:**
- Create: `lib/data/secure/secure_key_store.dart`
- Test: `test/unit/secure_key_store_test.dart`

**Interfaces:**
- Consumes: nulla.
- Produces: `SecureKeyStore` (interfaccia) con:
  - `Future<void> write(String key, String value)`
  - `Future<String?> read(String key)`
  - `Future<void> delete(String key)`
- E `FlutterSecureKeyStore implements SecureKeyStore` (wrapper su `FlutterSecureStorage` con `AndroidOptions(encryptedSharedPreferences: true)`).

- [ ] **Step 1: Scrivi il test fallito con fake in-memory**

`test/unit/secure_key_store_test.dart`:

```dart
import 'package:application/data/secure/secure_key_store.dart';
import 'package:flutter_test/flutter_test.dart';

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
  group('SecureKeyStore contract', () {
    test('write then read returns value', () async {
      final store = InMemoryKeyStore();
      await store.write('dek', 'dGVzdA==');
      expect(await store.read('dek'), 'dGVzdA==');
    });

    test('read of missing key returns null', () async {
      final store = InMemoryKeyStore();
      expect(await store.read('missing'), isNull);
    });

    test('delete removes value', () async {
      final store = InMemoryKeyStore();
      await store.write('token', 'abc');
      await store.delete('token');
      expect(await store.read('token'), isNull);
    });

    test('FlutterSecureKeyStore implements the contract', () {
      expect(FlutterSecureKeyStore(), isA<SecureKeyStore>());
    });
  });
}
```

- [ ] **Step 2: Esegui il test per verificare che fallisca**

Run: `flutter test test/unit/secure_key_store_test.dart`
Expected: FAIL — file `secure_key_store.dart` mancante.

- [ ] **Step 3: Scrivi l'implementazione minima**

`lib/data/secure/secure_key_store.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureKeyStore {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class FlutterSecureKeyStore implements SecureKeyStore {
  FlutterSecureKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(String key, String value) => _storage.write(
        key: key,
        value: value,
      );

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
```

- [ ] **Step 4: Esegui il test per verificare che passi**

Run: `flutter test test/unit/secure_key_store_test.dart`
Expected: PASS (4 test).

- [ ] **Step 5: Commit**

```bash
git add application/lib/data/secure/secure_key_store.dart application/test/unit/secure_key_store_test.dart
git commit -m "feat(secure): SecureKeyStore astrazione flutter_secure_storage"
```

---

### Task 5: Verifica completa fase + push

- [ ] **Step 1: Esegui l'intera suite di test del progetto**

Run: `flutter test`
Expected: PASS — tutti i test esistenti + i 18 nuovi (6 crypto + 5 payload + 5 encryption + 3 envelope... i numeri esatti: crypto_service 14, encrypted_payload 5, secure_key_store 4).

- [ ] **Step 2: Esegui l'analisi statica**

Run: `flutter analyze`
Expected: NO issues.

- [ ] **Step 3: Verifica che nessun segreto sia nei file committati**

Run: `git grep -iE "nvapi|password|dbu4475407|44ze" -- application/lib application/test || true`
Expected: nessun match (il comando non deve trovare nulla).

- [ ] **Step 4: Push**

```bash
git push origin main
```
Expected: push riuscito su `https://github.com/WebDev-Innovations/MentalMood.git`.
