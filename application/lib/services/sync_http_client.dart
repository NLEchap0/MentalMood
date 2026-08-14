import 'dart:convert';

import 'package:application/data/sync/sync_models.dart';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;

abstract class SyncHttpClient {
  Future<Map<String, dynamic>> postSync({
    required String baseUrl,
    required String accessToken,
    required String syncKey,
    required Map<String, dynamic> body,
  });
}

class HttpSyncClient implements SyncHttpClient {
  HttpSyncClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<Map<String, dynamic>> postSync({
    required String baseUrl,
    required String accessToken,
    required String syncKey,
    required Map<String, dynamic> body,
  }) async {
    final raw = jsonEncode(body);
    final signature = await _hmacHex(syncKey, raw);
    final uri = Uri.parse('$baseUrl/sync');
    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'X-Sync-Signature': signature,
        },
        body: raw,
      );
      final decoded = jsonDecode(response.body);
      if (response.statusCode != 200) {
        final error = decoded is Map<String, dynamic>
            ? decoded['error'] as Map<String, dynamic>?
            : null;
        throw SyncFailure(
          statusCode: response.statusCode,
          code: (error?['code'] as String?) ?? 'unknown',
          message: (error?['message'] as String?) ?? '',
        );
      }
      return (decoded as Map<String, dynamic>);
    } on SyncFailure {
      rethrow;
    } catch (_) {
      throw const SyncFailure(
        statusCode: 0,
        code: 'network_error',
        message: '',
      );
    }
  }

  Future<String> _hmacHex(String key, String data) async {
    final hmac = Hmac.sha256();
    final mac = await hmac.calculateMac(
      utf8.encode(data),
      secretKey: SecretKey(utf8.encode(key)),
    );
    return mac.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
