import 'package:application/data/repositories/user_repository.dart';
import 'package:application/domain/models.dart';
import 'package:flutter/foundation.dart';

/// Sessione utente. L'account reale è il cloud: questo controller gestisce
/// solo la cache drift locale (id/username derivati dalla sessione cloud)
/// usata dalle mood entries e dalla UI. Non autentica più nulla.
class AuthController extends ChangeNotifier {
  final UserRepository userRepository;

  AuthController({required this.userRepository});

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  /// Restores the session (if any) at app startup.
  Future<bool> isLoggedIn() async {
    return _currentUser != null;
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  /// Starts a session for a cloud-authenticated user (local cache only).
  Future<void> startSession(AppUser user) async {
    _currentUser = user;
    notifyListeners();
  }

  /// Reloads the current user's profile from storage.
  Future<void> refreshProfile() async {
    final user = _currentUser;
    if (user == null) return;
    _currentUser = await userRepository.getUserByUsername(user.username);
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String surname,
    required DateTime birthDate,
  }) async {
    final user = _currentUser;
    if (user == null) return false;

    final success = await userRepository.updateUser(
      id: user.id,
      name: name.trim(),
      surname: surname.trim(),
      birthDate: birthDate,
    );
    if (success) {
      _currentUser = await userRepository.getUserByUsername(user.username);
      notifyListeners();
    }
    return success;
  }

  Future<bool> deleteAccount() async {
    final user = _currentUser;
    if (user == null) return false;

    // Moods and badges are removed by the DB foreign-key cascade.
    final deletedCount = await userRepository.deleteUser(user.id);
    if (deletedCount > 0) {
      await logout();
      return true;
    }
    return false;
  }
}
