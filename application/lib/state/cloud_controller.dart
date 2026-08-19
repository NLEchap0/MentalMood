import 'dart:convert';

import 'package:application/data/repositories/user_repository.dart';
import 'package:application/data/secure/secure_key_store.dart';
import 'package:application/domain/services/crypto_service.dart';
import 'package:application/domain/services/encrypted_payload.dart';
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

  /// Exposes the API client (e.g. for checkout/plans).
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
      
      // Encrypt profile data for E2EE
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

      // Login immediately after registration to establish session
      await _loginAfterRegister(
        username,
        password,
        email: email,
        name: name,
        surname: surname,
        birthDate: birthDate,
        nameCipher: nameCipher,
        surnameCipher: surnameCipher,
        birthDateCipher: birthDateCipher,
      );
      
      _setLoading(false);
      return true;
    } on CloudApiFailure catch (e) {
      _errorCode = e.code;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorCode = 'unexpected_error';
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
      await _restoreDek(session, password);

      await _persistSession(session);
      _setLoading(false);
      return true;
    } on CloudApiFailure catch (e) {
      _errorCode = e.code;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorCode = 'unexpected_error';
      _setLoading(false);
      return false;
    }
  }

  Future<void> _restoreDek(AuthSession session, String password) async {
    try {
      final salt = session.kekSalt;
      final wrappedB64 = session.wrappedDek;
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
    } catch (_) {}
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
      email: await _store.read('cloud_email'),
      name: await _store.read('cloud_name'),
      surname: await _store.read('cloud_surname'),
      birthDate: DateTime.tryParse(await _store.read('cloud_birth_date') ?? ''),
      nameCipher: await _store.read('cloud_name_cipher'),
      surnameCipher: await _store.read('cloud_surname_cipher'),
      birthDateCipher: await _store.read('cloud_birth_date_cipher'),
      kekSalt: await _store.read('cloud_kek_salt'),
      wrappedDek: await _store.read('cloud_wrapped_dek'),
    );
    
    _consentEnabled = await _store.read('cloud_consent') == 'true';
    await _syncLocalUser(_session!);
    
    // Ensure all local entries belong to the correct cloud user ID
    // before we even try to sync.
    await _migrateLocalEntries(_session!);

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
      'cloud_email',
      'cloud_name',
      'cloud_surname',
      'cloud_birth_date',
      'cloud_name_cipher',
      'cloud_surname_cipher',
      'cloud_birth_date_cipher',
      'cloud_wrapped_dek',
    ]) {
      await _store.delete(key);
    }
    await _authController.logout();
    notifyListeners();
  }

  /// Ensures a valid access token: if the refresh token is present and
  /// the session has been restored, rotates tokens via /refresh.
  /// Returns false (and logs out) if refresh fails with 401/403.
  Future<bool> ensureFreshSession() async {
    final session = _session;
    if (session == null) return false;
    if (session.refreshToken.isEmpty) return true;
    try {
      final fresh = await _api.refresh(session.refreshToken);
      // Merge tokens with existing profile data using copyWith
      _session = session.copyWith(
        accessToken: fresh.accessToken,
        refreshToken: fresh.refreshToken,
        syncKey: fresh.syncKey,
        plan: fresh.plan,
        status: fresh.status,
        kekSalt: fresh.kekSalt,
        wrappedDek: fresh.wrappedDek,
        nameCipher: fresh.nameCipher,
        surnameCipher: fresh.surnameCipher,
        birthDateCipher: fresh.birthDateCipher,
      );
      await _persistSession(_session!);
      return true;
    } on CloudApiFailure catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403 || e.code == 'auth_error' || e.code == 'token_invalid') {
        await logoutCloud();
        return false;
      }
      return true;
    }
  }

  Future<String?> checkoutCloud(String plan) async {
    final session = _session;
    if (session == null) return null;
    try {
      return await _api.checkout(
        accessToken: session.accessToken,
        plan: plan,
        email: session.email,
      );
    } on CloudApiFailure catch (e) {
      if ((e.statusCode == 401 || e.code == 'auth_error') && await ensureFreshSession()) {
        return checkoutCloud(plan);
      }
      _errorCode = e.code;
      notifyListeners();
      return null;
    }
  }

  Future<bool> refreshSubscription() async {
    final session = _session;
    if (session == null) return false;
    try {
      _subscription = await _api.subscription(session.accessToken);
      // Update session plan to match subscription info for UI consistency
      if (_subscription != null) {
        _session = session.copyWith(
          plan: _subscription!.plan,
          status: _subscription!.status,
        );
        await _persistSession(_session!);
      }
      notifyListeners();
      return true;
    } on CloudApiFailure catch (e) {
      if ((e.statusCode == 401 || e.code == 'auth_error') && await ensureFreshSession()) {
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
      if ((e.statusCode == 401 || e.code == 'auth_error') && await ensureFreshSession()) {
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

  Future<bool> updateProfileCloud({
    required String name,
    required String surname,
    required DateTime birthDate,
  }) async {
    final session = _session;
    if (session == null) return false;
    final dek = await cloudDek();
    if (dek == null) return false;

    try {
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

      await _api.updateProfile(
        accessToken: session.accessToken,
        nameCipher: nameCipher,
        surnameCipher: surnameCipher,
        birthDateCipher: birthDateCipher,
      );

      // Update local session to match
      _session = session.copyWith(
        name: name,
        surname: surname,
        birthDate: birthDate,
        nameCipher: nameCipher,
        surnameCipher: surnameCipher,
        birthDateCipher: birthDateCipher,
      );
      await _persistSession(_session!);
      return true;
    } on CloudApiFailure catch (e) {
      if ((e.statusCode == 401 || e.code == 'auth_error') && await ensureFreshSession()) {
        return updateProfileCloud(name: name, surname: surname, birthDate: birthDate);
      }
      _errorCode = e.code;
      return false;
    } catch (e) {
      _errorCode = 'unexpected_error';
      return false;
    }
  }

  Future<bool> changePasswordCloud({
    required String oldPassword,
    required String newPassword,
  }) async {
    final session = _session;
    if (session == null) return false;

    try {
      // 1. Get current E2EE components
      final currentSalt = session.kekSalt;
      final currentWrapped = session.wrappedDek;
      if (currentSalt == null || currentWrapped == null) {
        _errorCode = 'e2ee_not_initialized';
        return false;
      }

      // 2. Derive old KEK and unwrap DEK to ensure oldPassword is correct and we have the DEK
      final oldKek = await _crypto.deriveKek(
        password: oldPassword,
        salt: _hexToBytes(currentSalt),
      );
      final dek = await _crypto.unwrapDek(
        wrappedDek: base64Decode(currentWrapped),
        kek: oldKek,
      );

      // 3. Generate new E2EE components for the new password
      final newSalt = await _crypto.generateSalt();
      final newKek = await _crypto.deriveKek(
        password: newPassword,
        salt: _hexToBytes(newSalt),
      );
      final newWrapped = await _crypto.wrapDek(dek: dek, kek: newKek);

      // 4. Send to API
      await _api.changePassword(
        accessToken: session.accessToken,
        oldPassword: oldPassword,
        newPassword: newPassword,
        newKekSalt: newSalt,
        newWrappedDek: base64Encode(newWrapped),
      );

      // 5. Update local session and storage
      _session = session.copyWith(
        kekSalt: newSalt,
        wrappedDek: base64Encode(newWrapped),
      );
      await _store.write('cloud_kek_salt', newSalt);
      await _store.write('cloud_wrapped_dek', base64Encode(newWrapped));
      
      notifyListeners();
      return true;
    } on SecretBoxAuthenticationError {
      _errorCode = 'invalid_credentials';
      return false;
    } on CloudApiFailure catch (e) {
      if ((e.statusCode == 401 || e.code == 'auth_error') && await ensureFreshSession()) {
        return changePasswordCloud(oldPassword: oldPassword, newPassword: newPassword);
      }
      _errorCode = e.code;
      return false;
    } catch (e) {
      _errorCode = 'unexpected_error';
      return false;
    }
  }

  Future<bool> deleteCloudAccount() async {
    final session = _session;
    if (session == null) {
      debugPrint('CloudController: delete attempt with null session');
      return false;
    }
    try {
      debugPrint('CloudController: deleting account for ${session.username}');
      await _api.deleteAccount(session.accessToken);
      // Also clear the local drift cache (mood entries, badges).
      final user = _authController.currentUser;
      if (user != null) {
        await _userRepository.deleteUser(user.id);
      }
      await logoutCloud();
      return true;
    } on CloudApiFailure catch (e) {
      if ((e.statusCode == 401 || e.code == 'auth_error') && await ensureFreshSession()) {
        return deleteCloudAccount();
      }
      _errorCode = e.code;
      debugPrint('CloudController: delete failed with ${e.code}');
      return false;
    } catch (e) {
      _errorCode = 'unexpected_error';
      debugPrint('CloudController: delete local error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> exportCloudData() async {
    final session = _session;
    if (session == null) return null;
    try {
      return await _api.exportData(session.accessToken);
    } on CloudApiFailure catch (e) {
      if ((e.statusCode == 401 || e.code == 'auth_error') && await ensureFreshSession()) {
        return exportCloudData();
      }
      _errorCode = e.code;
      return null;
    }
  }

  Future<bool> wipeCloudData({DateTime? before}) async {
    final session = _session;
    if (session == null) return false;
    try {
      await _api.wipeData(session.accessToken, before: before);
      return true;
    } on CloudApiFailure catch (e) {
      if ((e.statusCode == 401 || e.code == 'auth_error') && await ensureFreshSession()) {
        return wipeCloudData(before: before);
      }
      _errorCode = e.code;
      return false;
    }
  }

  /// Hexadecimal DEK for the SyncService (if a cloud session is present).
  Future<SecretKey?> cloudDek() async {
    final hex = await _store.read('cloud_dek');
    if (hex == null) return null;
    return _crypto.dekFromBytes(_hexToBytes(hex));
  }

  Future<void> _loginAfterRegister(
    String username,
    String password, {
    String? email,
    String? name,
    String? surname,
    DateTime? birthDate,
    String? nameCipher,
    String? surnameCipher,
    String? birthDateCipher,
  }) async {
    final session = await _api.login(identifier: username, password: password);
    final merged = session.copyWith(
      email: email,
      name: name,
      surname: surname,
      birthDate: birthDate,
      nameCipher: nameCipher,
      surnameCipher: surnameCipher,
      birthDateCipher: birthDateCipher,
    );
    await _persistSession(merged);
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
    if (session.email != null) await _store.write('cloud_email', session.email!);
    if (session.name != null) await _store.write('cloud_name', session.name!);
    if (session.surname != null) await _store.write('cloud_surname', session.surname!);
    if (session.birthDate != null) {
      await _store.write('cloud_birth_date', session.birthDate!.toIso8601String());
    }
    if (session.nameCipher != null) {
      await _store.write('cloud_name_cipher', session.nameCipher!);
    }
    if (session.surnameCipher != null) {
      await _store.write('cloud_surname_cipher', session.surnameCipher!);
    }
    if (session.birthDateCipher != null) {
      await _store.write('cloud_birth_date_cipher', session.birthDateCipher!);
    }
    if (session.kekSalt != null) {
      await _store.write('cloud_kek_salt', session.kekSalt!);
    }
    if (session.wrappedDek != null) {
      await _store.write('cloud_wrapped_dek', session.wrappedDek!);
    }
    _consentEnabled = false;
    await _store.write('cloud_consent', 'false');
    await _syncLocalUser(session);
    notifyListeners();
  }

  /// The cloud account is the only one: it maintains the drift cache (same username)
  /// for mood entries and badges, without ever authenticating locally.
  Future<void> _syncLocalUser(AuthSession session) async {
    try {
      String name = session.name ?? session.username;
      String surname = session.surname ?? '';
      DateTime birthDate = session.birthDate ?? DateTime(2000);

      // If E2EE ciphers are present and we have the DEK, decrypt them.
      final dek = await cloudDek();
      if (dek != null) {
        if (session.nameCipher != null && session.nameCipher != '') {
          try {
            name = _crypto.decryptString(
              EncryptedPayload.fromBytes(base64Decode(session.nameCipher!)),
              dek,
            );
          } catch (e) {
            debugPrint('CloudController: name decryption failed: $e');
          }
        }
        if (session.surnameCipher != null && session.surnameCipher != '') {
          try {
            surname = _crypto.decryptString(
              EncryptedPayload.fromBytes(base64Decode(session.surnameCipher!)),
              dek,
            );
          } catch (e) {
            debugPrint('CloudController: surname decryption failed: $e');
          }
        }
        if (session.birthDateCipher != null && session.birthDateCipher != '') {
          try {
            final dateStr = _crypto.decryptString(
              EncryptedPayload.fromBytes(base64Decode(session.birthDateCipher!)),
              dek,
            );
            birthDate = DateTime.parse(dateStr);
          } catch (e) {
            debugPrint('CloudController: birthDate decryption failed: $e');
          }
        }
      }

      final existing = await _userRepository.getUserByUsername(session.username);
      if (existing != null) {
        await _userRepository.updateUser(
          id: existing.id,
          name: name,
          surname: surname,
          birthDate: birthDate,
        );
        final updated = await _userRepository.getUserByUsername(session.username);
        await _authController.startSession(updated!);
        return;
      }
      final user = await _userRepository.createUser(
        username: session.username,
        name: name,
        surname: surname,
        password: 'cloud-only',
        birthDate: birthDate,
      );
      await _authController.startSession(user);
    } catch (e) {
      debugPrint('CloudController: sync local user failed: $e');
    }
  }

  Future<void> _migrateLocalEntries(AuthSession session) async {
    try {
      final db = (_userRepository as dynamic).db as dynamic; 
      // This is a shortcut to reach the drift DB from the repo
      // to reassign existing rows from previous sessions or 'Default User'
      // to the new authenticated Cloud ID.
      await db.customStatement(
        'UPDATE emotion SET user_id = ? WHERE user_id != ?',
        [session.id, session.id],
      );
      debugPrint('CloudController: migrated local entries to user ${session.id}');
    } catch (e) {
      debugPrint('CloudController: migration failed (might not be needed): $e');
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
