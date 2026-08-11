import 'package:application/data/repositories/user_repository.dart';
import 'package:application/domain/models.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles authentication, session persistence and profile management.
class AuthController extends ChangeNotifier {
  final UserRepository userRepository;
  static const String _sessionKey = 'user_session';

  AuthController({required this.userRepository});

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final user = await userRepository.getUserByUsername(username.trim());
      if (user != null && BCrypt.checkpw(password, user.passwordHash)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, user.username);
        _currentUser = user;
        _setLoading(false);
        return true;
      }
      _errorMessage = 'Invalid username or password.';
    } catch (e) {
      debugPrint('Login error: $e');
      _errorMessage = 'An error occurred. Please try again later.';
    }
    _setLoading(false);
    return false;
  }

  /// Restores the session (if any) at app startup.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString(_sessionKey);
    if (username != null) {
      _currentUser = await userRepository.getUserByUsername(username);
      return _currentUser != null;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _currentUser = null;
    notifyListeners();
  }

  /// Starts a session for a freshly registered user (auto-login).
  Future<void> startSession(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.username);
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

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }
}
