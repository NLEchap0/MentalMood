import 'package:application/services/ai_api_client.dart';
import 'package:flutter/foundation.dart';

enum AiState { idle, loading, success, error, paymentRequired, consentRequired }

class AiController extends ChangeNotifier {
  AiController({required this._apiClient});

  final AiApiClient _apiClient;

  AiState _state = AiState.idle;
  AiState get state => _state;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _lastReply;
  String? get lastReply => _lastReply;

  List<AiInsight> _insights = [];
  List<AiInsight> get insights => _insights;

  bool _hasConsent = false;
  bool get hasConsent => _hasConsent;

  @visibleForTesting
  set lastReplyForTest(String? value) => _lastReply = value;

  Future<bool> sendChat({
    required String baseUrl,
    required String accessToken,
    required String message,
  }) {
    return _guard(() => _apiClient.chat(
      baseUrl: baseUrl,
      accessToken: accessToken,
      message: message,
    ));
  }

  Future<bool> sendAdvice({
    required String baseUrl,
    required String accessToken,
    required String context,
  }) {
    return _guard(() => _apiClient.advice(
      baseUrl: baseUrl,
      accessToken: accessToken,
      context: context,
    ));
  }

  Future<bool> sendCbt({
    required String baseUrl,
    required String accessToken,
    required String thought,
    required String situation,
  }) {
    return _guard(() => _apiClient.cbt(
      baseUrl: baseUrl,
      accessToken: accessToken,
      thought: thought,
      situation: situation,
    ));
  }

  Future<bool> enableConsent({
    required String baseUrl,
    required String accessToken,
  }) async {
    _setLoading();
    try {
      _hasConsent = await _apiClient.setConsent(
        baseUrl: baseUrl,
        accessToken: accessToken,
        consent: true,
      );
      _state = AiState.success;
      notifyListeners();
      return true;
    } on AiFailure catch (e) {
      _fail(e);
      return false;
    }
  }

  Future<bool> revokeConsent({
    required String baseUrl,
    required String accessToken,
  }) async {
    _setLoading();
    try {
      await _apiClient.setConsent(
        baseUrl: baseUrl,
        accessToken: accessToken,
        consent: false,
      );
      _hasConsent = false;
      _lastReply = null;
      _insights = [];
      _state = AiState.success;
      notifyListeners();
      return true;
    } on AiFailure catch (e) {
      _fail(e);
      return false;
    }
  }

  Future<void> loadInsights({
    required String baseUrl,
    required String accessToken,
  }) async {
    _setLoading();
    try {
      _insights = await _apiClient.insights(
        baseUrl: baseUrl,
        accessToken: accessToken,
      );
      _state = AiState.success;
      notifyListeners();
    } on AiFailure catch (e) {
      _fail(e);
    }
  }

  Future<bool> _guard(Future<String> Function() call) async {
    _setLoading();
    try {
      _lastReply = await call();
      _state = AiState.success;
      notifyListeners();
      return true;
    } on AiFailure catch (e) {
      _fail(e);
      return false;
    }
  }

  void _setLoading() {
    _state = AiState.loading;
    _errorCode = null;
    notifyListeners();
  }

  void _fail(AiFailure e) {
    _state = switch (e.code) {
      'payment_required' => AiState.paymentRequired,
      'consent_required' => AiState.consentRequired,
      _ => AiState.error,
    };
    _errorCode = e.code;
    notifyListeners();
  }
}
