import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// URL base dell'API. Su emulatore Android `10.0.2.2` = host locale.
/// Su produzione IONOS senza mod_rewrite gli endpoint vanno chiamati
/// come `/index.php/<endpoint>` (la DirectoryIndex gestisce la root).
String apiBaseUrl() =>
    dotenv.maybeGet('API_BASE_URL') ?? 'http://10.0.2.2:8090';

/// Ritorna l'URL completo per un path API, gestendo il deploy IONOS
/// senza mod_rewrite (via `/index.php/<endpoint>`).
String apiEndpoint(String path) {
  final base = apiBaseUrl().replaceAll(RegExp(r'/+$'), '');
  final normalized = path.startsWith('/') ? path : '/$path';
  if (base.contains('webdevinnovations.ch')) {
    return '$base/index.php$normalized';
  }
  return '$base$normalized';
}

class CloudApiFailure implements Exception {
  const CloudApiFailure({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  final int statusCode;
  final String code;
  final String message;

  @override
  String toString() => 'CloudApiFailure($statusCode, $code)';
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.syncKey,
    required this.username,
    required this.plan,
    required this.status,
    this.trialEndsAt,
    this.currentPeriodEnd,
  });

  final String accessToken;
  final String refreshToken;
  final String syncKey;
  final String username;
  final String plan;
  final String status;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;

  bool get isPro => plan == 'pro' && (status == 'active' || status == 'trialing');
  bool get canSync => plan != 'free' || (trialEndsAt?.isAfter(DateTime.now()) ?? false);
}

class SubscriptionInfo {
  const SubscriptionInfo({
    required this.plan,
    required this.status,
    this.trialEndsAt,
    this.currentPeriodEnd,
    required this.aiCredits,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? v) => v == null ? null : DateTime.tryParse(v);
    return SubscriptionInfo(
      plan: json['plan'] as String? ?? 'free',
      status: json['status'] as String? ?? 'none',
      trialEndsAt: parse(json['trial_ends_at'] as String?),
      currentPeriodEnd: parse(json['current_period_end'] as String?),
      aiCredits: (json['ai_credits'] as num?)?.toInt() ?? 0,
    );
  }

  final String plan;
  final String status;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;
  final int aiCredits;
}

class ConsentResult {
  const ConsentResult({required this.consent, required this.deleted});

  final bool consent;
  final int deleted;
}

class AuthApiClient {
  AuthApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String kekSalt,
    required String wrappedDek,
  }) async {
    return _guard(() async {
      final response = await _client.post(
        Uri.parse(apiEndpoint('/register')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'kek_salt': kekSalt,
          'wrapped_dek': wrappedDek,
        }),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw _failure(response);
    });
  }

  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    return _guard(() async {
      final response = await _client.post(
        Uri.parse(apiEndpoint('/login')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>;
        return AuthSession(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
          syncKey: data['sync_key'] as String,
          username: user['username'] as String,
          plan: user['plan'] as String? ?? 'free',
          status: user['subscription_status'] as String? ?? 'none',
          trialEndsAt: _parseDate(user['trial_ends_at'] as String?),
        );
      }
      throw _failure(response);
    });
  }

  Future<SubscriptionInfo> subscription(String accessToken) async {
    return _guard(() async {
      final response = await _client.get(
        Uri.parse(apiEndpoint('/subscription')),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        return SubscriptionInfo.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      throw _failure(response);
    });
  }

  Future<ConsentResult> setConsent({
    required String accessToken,
    required bool consent,
  }) async {
    return _guard(() async {
      final response = await _client.post(
        Uri.parse(apiEndpoint('/consent')),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'consent': consent}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ConsentResult(
          consent: data['consent'] == true,
          deleted: (data['deleted'] as num?)?.toInt() ?? 0,
        );
      }
      throw _failure(response);
    });
  }

  Future<Map<String, dynamic>> exportData(String accessToken) async {
    return _guard(() async {
      final response = await _client.get(
        Uri.parse(apiEndpoint('/export')),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw _failure(response);
    });
  }

  Future<void> deleteAccount(String accessToken) async {
    return _guard(() async {
      final response = await _client.delete(
        Uri.parse(apiEndpoint('/account')),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode != 200) {
        throw _failure(response);
      }
    });
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CloudApiFailure {
      rethrow;
    } catch (_) {
      throw const CloudApiFailure(
        statusCode: 0,
        code: 'network_error',
        message: '',
      );
    }
  }

  CloudApiFailure _failure(http.Response response) {
    String code = 'unknown';
    String message = '';
    try {
      final error =
          (jsonDecode(response.body) as Map<String, dynamic>)['error']
              as Map<String, dynamic>;
      code = (error['code'] as String?) ?? 'unknown';
      message = (error['message'] as String?) ?? '';
    } catch (_) {
      code = response.statusCode >= 500 ? 'server_error' : 'unknown';
    }
    return CloudApiFailure(
      statusCode: response.statusCode,
      code: code,
      message: message,
    );
  }

  DateTime? _parseDate(String? v) {
    if (v == null) return null;
    return DateTime.tryParse(v);
  }
}
