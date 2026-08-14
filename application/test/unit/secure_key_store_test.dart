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
