import 'package:application/DataBase/database.dart';
import 'package:application/Repositories/user_repository.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends ChangeNotifier {
  final UserRepository userRepository;
  static const String _sessionKey = 'user_session';

  LoginController({required this.userRepository});

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserData? _currentUser;
  UserData? get currentUser => _currentUser;
  set currentUser(UserData? user) => _currentUser = user;

  /// Handles the login process and saves the session if successful
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await userRepository.getUserByUsername(username.trim());

      if (user != null && BCrypt.checkpw(password, user.password)) {
        // Save session locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, user.username);
        
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid username or password.';
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _errorMessage = 'An error occurred. Please try again later.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Checks if a user is already logged in and loads their data
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString(_sessionKey);
    
    if (username != null) {
      _currentUser = await userRepository.getUserByUsername(username);
      return _currentUser != null;
    }
    return false;
  }

  /// Clears the saved session (Logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _currentUser = null;
    notifyListeners();
  }

  /// Updates current user profile info
  Future<bool> updateProfile({
    required String name,
    required String surname,
    required DateTime birthDate,
  }) async {
    if (_currentUser == null) return false;

    final updatedUser = _currentUser!.toCompanion(true).copyWith(
          name: Value(name.trim()),
          surname: Value(surname.trim()),
          birthDate: Value(birthDate),
        );

    final success = await userRepository.updateUser(updatedUser);
    if (success) {
      _currentUser = await userRepository.getUserByUsername(_currentUser!.username);
      notifyListeners();
    }
    return success;
  }

  /// Deletes the current user account and all associated data
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;

    // The user deletion will happen here.
    // Note: Associating mood deletion here or relying on DB constraints.
    final deletedCount = await userRepository.deleteUser(_currentUser!.id);
    
    if (deletedCount > 0) {
      await logout();
      return true;
    }
    return false;
  }
}
