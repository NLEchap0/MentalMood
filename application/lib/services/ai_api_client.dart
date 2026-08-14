import 'dart:convert';

import 'package:http/http.dart' as http;

class AiFailure implements Exception {
  const AiFailure({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() => 'AiFailure($statusCode, $code)';
}

class AiInsight {
  const AiInsight({
    required this.kind,
    required this.content,
    required this.createdAt,
  });

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      kind: json['kind'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }

  final String kind;
  final String content;
  final DateTime createdAt;
}

abstract class AiApiClient {
  Future<String> chat({
    required String baseUrl,
    required String accessToken,
    required String message,
  });

  Future<String> advice({
    required String baseUrl,
    required String accessToken,
    required String context,
  });

  Future<String> cbt({
    required String baseUrl,
    required String accessToken,
    required String thought,
    required String situation,
  });

  Future<bool> setConsent({
    required String baseUrl,
    required String accessToken,
    required bool consent,
  });

  Future<int> revokeAiData({
    required String baseUrl,
    required String accessToken,
  });

  Future<List<AiInsight>> insights({
    required String baseUrl,
    required String accessToken,
  });
}

class HttpAiApiClient implements AiApiClient {
  HttpAiApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<String> chat({
    required String baseUrl,
    required String accessToken,
    required String message,
  }) async {
    final data = await _post(
      baseUrl: baseUrl,
      accessToken: accessToken,
      path: '/ai/chat',
      body: {'message': message},
    );
    return data['reply'] as String;
  }

  @override
  Future<String> advice({
    required String baseUrl,
    required String accessToken,
    required String context,
  }) async {
    final data = await _post(
      baseUrl: baseUrl,
      accessToken: accessToken,
      path: '/ai/advice',
      body: {'context': context},
    );
    return data['reply'] as String;
  }

  @override
  Future<String> cbt({
    required String baseUrl,
    required String accessToken,
    required String thought,
    required String situation,
  }) async {
    final data = await _post(
      baseUrl: baseUrl,
      accessToken: accessToken,
      path: '/ai/cbt',
      body: {'thought': thought, 'situation': situation},
    );
    return data['reply'] as String;
  }

  @override
  Future<bool> setConsent({
    required String baseUrl,
    required String accessToken,
    required bool consent,
  }) async {
    final data = await _post(
      baseUrl: baseUrl,
      accessToken: accessToken,
      path: '/consent',
      body: {'consent': consent},
    );
    return data['consent'] == true;
  }

  @override
  Future<int> revokeAiData({
    required String baseUrl,
    required String accessToken,
  }) async {
    final uri = Uri.parse('$baseUrl/ai-data');
    try {
      final response = await _client.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      final decoded = _decode(response);
      return (decoded['deleted'] as num?)?.toInt() ?? 0;
    } on AiFailure {
      rethrow;
    } catch (_) {
      throw const AiFailure(statusCode: 0, code: 'network_error', message: '');
    }
  }

  @override
  Future<List<AiInsight>> insights({
    required String baseUrl,
    required String accessToken,
  }) async {
    final uri = Uri.parse('$baseUrl/ai/insights');
    try {
      final response = await _client.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      final decoded = _decode(response);
      final raw = decoded['insights'] as List<dynamic>? ?? [];
      return raw
          .map((e) => AiInsight.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AiFailure {
      rethrow;
    } catch (_) {
      throw const AiFailure(statusCode: 0, code: 'network_error', message: '');
    }
  }

  Future<Map<String, dynamic>> _post({
    required String baseUrl,
    required String accessToken,
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );
      return _decode(response);
    } on AiFailure {
      rethrow;
    } catch (_) {
      throw const AiFailure(statusCode: 0, code: 'network_error', message: '');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    String code = 'unknown';
    String message = '';
    try {
      final error = (jsonDecode(response.body)
          as Map<String, dynamic>)['error'] as Map<String, dynamic>;
      code = (error['code'] as String?) ?? 'unknown';
      message = (error['message'] as String?) ?? '';
    } catch (_) {
      code = response.statusCode >= 500 ? 'server_error' : 'unknown';
    }
    throw AiFailure(
      statusCode: response.statusCode,
      code: code,
      message: message,
    );
  }
}
