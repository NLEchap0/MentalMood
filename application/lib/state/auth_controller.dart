import 'package:application/data/repositories/user_repository.dart';
import 'package:application/domain/models.dart';
import 'package:flutter/foundation.dart';

/// User session. The real account is on the cloud: this controller manages
/// only the local drift cache (id/username derived from the cloud session)
/// used by mood entries and the UI. It no longer authenticates anything.
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
    String? email,
  }) async {
    final user = _currentUser;
    if (user == null) return false;

    final success = await userRepository.updateUser(
      id: user.id,
      name: name.trim(),
      surname: surname.trim(),
      birthDate: birthDate,
      email: email,
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
