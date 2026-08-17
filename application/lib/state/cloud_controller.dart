import 'dart:convert';

import 'package:application/data/repositories/user_repository.dart';
import 'package:application/data/secure/secure_key_store.dart';
import 'package:application/domain/services/crypto_service.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/state/auth_controller.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

/// Manages the cloud session (login/register with the API),
/// subscription state, and AI consent. The session is stored in flutter_secure_storage.
/// The cloud account is the ONLY account: after authentication it synchronizes
/// the local drift cache (same username) for mood entries.
class CloudController extends ChangeNotifier {
  CloudController({
    required AuthApiClient apiClient,
    required SecureKeyStore keyStore,
    required CryptoService crypto,
    required UserRepository userRepository,
    required AuthController authController,
  })  : _api = apiClient,
        _store = keyStore,
        _crypto = crypto,
        _userRepository = userRepository,
        _authController = authController;

  final AuthApiClient _api;
  final SecureKeyStore _store;
  final CryptoService _crypto;
  final UserRepository _userRepository;
  final AuthController _authController;

  /// Espone il client API (es. per checkout/piani).
  AuthApiClient get api => _api;

  AuthSession? _session;
  AuthSession? get session => _session;

  SubscriptionInfo? _subscription;
  SubscriptionInfo? get subscription => _subscription;

  bool _consentEnabled = false;
  bool get consentEnabled => _consentEnabled;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _lastSyncResult;
  String? get lastSyncResult => _lastSyncResult;

  void setSyncResult(String value) {
    _lastSyncResult = value;
    notifyListeners();
  }

  bool get isConnected => _session != null;

  Future<bool> registerCloud({
    required String username,
    required String password,
    required String email,
    required String name,
    required String surname,
    required DateTime birthDate,
  }) async {
    _setLoading(true);
    try {
      final dek = await _crypto.generateDek();
      final salt = await _crypto.generateSalt();
      final saltBytes = _hexToBytes(salt);
      final kek = await _crypto.deriveKek(password: password, salt: saltBytes);
      final wrapped = await _crypto.wrapDek(dek: dek, kek: kek);

      debugPrint('DEBUG: Registering user $username with email $email');
      final nameCipher = base64Encode(
        (await _crypto.encryptString(name, dek)).toBytes(),
      );
      final surnameCipher = base64Encode(
        (await _crypto.encryptString(surname, dek)).toBytes(),
      );
      final birthDateCipher = base64Encode(
        (await _crypto.encryptString(
          birthDate.toIso8601String().split('T')[0],
          dek,
        ))
            .toBytes(),
      );
      await _api.register(
        username: username,
        password: password,
        email: email,
        kekSalt: salt,
        wrappedDek: base64Encode(wrapped),
        nameCipher: nameCipher,
        surnameCipher: surnameCipher,
        birthDateCipher: birthDateCipher,
      );
      await _store.write('cloud_kek_salt', salt);
      await _store.write('cloud_dek', _bytesToHex(await dek.extractBytes()));

      await _loginAfterRegister(username, password);
      _setLoading(false);
      return true;
    } on CloudApiFailure catch (e) {
      _errorCode = e.code;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorCode = 'local_error: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginCloud({
    required String identifier,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final session = await _api.login(identifier: identifier, password: password);

      // Retrieves salt + wrapped DEK from the server to derive the local DEK.
      // If the DEK is not available (e.g., account registered from another
      // client with incomplete data) login still succeeds: only the
      // E2EE sync will not be available until the key is regenerated.
      await _restoreDek(session, password);

      await _persistSession(session);
      _setLoading(false);
      return true;
    } on CloudApiFailure catch (e) {
      _errorCode = e.code;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorCode = 'local_error: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> _restoreDek(AuthSession session, String password) async {
    try {
      final export = await _api.exportData(session.accessToken);
      final salt = export['kek_salt'] as String?;
      final wrappedB64 = export['wrapped_dek'] as String?;
      if (salt == null || wrappedB64 == null) return;
      final kek = await _crypto.deriveKek(
        password: password,
        salt: _hexToBytes(salt),
      );
      final dek = await _crypto.unwrapDek(
        wrappedDek: base64Decode(wrappedB64),
        kek: kek,
      );
      await _store.write('cloud_kek_salt', salt);
      await _store.write('cloud_dek', _bytesToHex(await dek.extractBytes()));
    } catch (e) {
      debugPrint('CloudController: DEK restore skipped: $e');
    }
  }

  Future<bool> restoreSession() async {
    final username = await _store.read('cloud_username');
    final accessToken = await _store.read('cloud_access_token');
    final refreshToken = await _store.read('cloud_refresh_token');
    final syncKey = await _store.read('cloud_sync_key');
    if (username == null || accessToken == null) return false;
    _session = AuthSession(
      id: int.tryParse(await _store.read('cloud_user_id') ?? '') ?? 0,
      accessToken: accessToken,
      refreshToken: refreshToken ?? '',
      syncKey: syncKey ?? '',
      username: username,
      plan: await _store.read('cloud_plan') ?? 'free',
      status: await _store.read('cloud_status') ?? 'none',
    );
    _consentEnabled = await _store.read('cloud_consent') == 'true';
    await _syncLocalUser(_session!);
    notifyListeners();
    // The saved token might be expired: try to rotate it immediately.
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await ensureFreshSession();
    }
    return _session != null;
  }

  Future<void> logoutCloud() async {
    _session = null;
    _subscription = null;
    _consentEnabled = false;
    for (final key in [
      'cloud_username',
      'cloud_user_id',
      'cloud_access_token',
      'cloud_refresh_token',
      'cloud_sync_key',
      'cloud_dek',
      'cloud_kek_salt',
      'cloud_plan',
      'cloud_status',
      'cloud_consent',
    ]) {
      await _store.delete(key);
    }
    await _authController.logout();
    notifyListeners();
  }

  /// Ensures a valid access token: if the refresh token is present and
  /// the session has been restored, rotates tokens via /refresh.
  /// Returns false (and logs out) if refresh fails.
  Future<bool> ensureFreshSession() async {
    final session = _session;
    if (session == null) return false;
    if (session.refreshToken.isEmpty) return true;
    try {
      final fresh = await _api.refresh(session.refreshToken);
      _session = fresh;
      await _store.write('cloud_username', fresh.username);
      await _store.write('cloud_access_token', fresh.accessToken);
      await _store.write('cloud_refresh_token', fresh.refreshToken);
      await _store.write('cloud_sync_key', fresh.syncKey);
      await _store.write('cloud_plan', fresh.plan);
      await _store.write('cloud_status', fresh.status);
      notifyListeners();
      return true;
    } on CloudApiFailure {
      await logoutCloud();
      return false;
    }
  }

  Future<bool> refreshSubscription() async {
    final session = _session;
    if (session == null) return false;
    try {
      _subscription = await _api.subscription(session.accessToken);
      notifyListeners();
      return true;
    } on CloudApiFailure catch (e) {
      if (e.statusCode == 401 && await ensureFreshSession()) {
        return refreshSubscription();
      }
      _errorCode = e.code;
      return false;
    }
  }

  Future<bool> setAiConsent(bool consent) async {
    final session = _session;
    if (session == null) return false;
    try {
      final result = await _api.setConsent(
        accessToken: session.accessToken,
        consent: consent,
      );
      _consentEnabled = result.consent;
      await _store.write('cloud_consent', result.consent ? 'true' : 'false');
      notifyListeners();
      return true;
    } on CloudApiFailure catch (e) {
      if (e.statusCode == 401 && await ensureFreshSession()) {
        return setAiConsent(consent);
      }
      _errorCode = e.code;
      return false;
    }
  }

  /// Requests a password reset: the server sends an email to the
  /// account address (if present). Always returns ok (anti-enumeration).
  Future<bool> requestPasswordReset(String identifier) async {
    try {
      await _api.requestPasswordReset(identifier);
      return true;
    } on CloudApiFailure catch (e) {
      _errorCode = e.code;
      return false;
    }
  }

  Future<bool> deleteCloudAccount() async {
    final session = _session;
    if (session == null) return false;
    try {
      await _api.deleteAccount(session.accessToken);
      // Also clear the local drift cache (mood entries, badges).
      final user = _authController.currentUser;
      if (user != null) {
        await _userRepository.deleteUser(user.id);
      }
      await logoutCloud();
      return true;
    } on CloudApiFailure catch (e) {
      if (e.statusCode == 401 && await ensureFreshSession()) {
        return deleteCloudAccount();
      }
      _errorCode = e.code;
      return false;
    }
  }

  Future<Map<String, dynamic>?> exportCloudData() async {
    final session = _session;
    if (session == null) return null;
    try {
      return await _api.exportData(session.accessToken);
    } on CloudApiFailure catch (e) {
      if (e.statusCode == 401 && await ensureFreshSession()) {
        return exportCloudData();
      }
      _errorCode = e.code;
      return null;
    }
  }

  /// Hexadecimal DEK for the SyncService (if a cloud session is present).
  Future<SecretKey?> cloudDek() async {
    final hex = await _store.read('cloud_dek');
    if (hex == null) return null;
    return _crypto.dekFromBytes(_hexToBytes(hex));
  }

  Future<void> _loginAfterRegister(String username, String password) async {
    final session = await _api.login(identifier: username, password: password);
    await _persistSession(session);
  }

  Future<void> _persistSession(AuthSession session) async {
    _session = session;
    await _store.write('cloud_username', session.username);
    await _store.write('cloud_user_id', session.id.toString());
    await _store.write('cloud_access_token', session.accessToken);
    await _store.write('cloud_refresh_token', session.refreshToken);
    await _store.write('cloud_sync_key', session.syncKey);
    await _store.write('cloud_plan', session.plan);
    await _store.write('cloud_status', session.status);
    _consentEnabled = false;
    await _store.write('cloud_consent', 'false');
    await _syncLocalUser(session);
    notifyListeners();
  }

  /// The cloud account is the only one: it maintains the drift cache (same username)
  /// for mood entries and badges, without ever authenticating locally.
  Future<void> _syncLocalUser(AuthSession session) async {
    try {
      final existing = await _userRepository.getUserByUsername(session.username);
      if (existing != null) {
        await _authController.startSession(existing);
        return;
      }
      final user = await _userRepository.createUser(
        username: session.username,
        name: session.username,
        surname: '',
        password: 'cloud-only',
        birthDate: DateTime(2000),
      );
      await _authController.startSession(user);
    } catch (e) {
      debugPrint('CloudController: sync local user failed: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorCode = null;
    notifyListeners();
  }

  List<int> _hexToBytes(String hex) {
    return [
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ];
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
