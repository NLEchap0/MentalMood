import 'package:application/DataBase/database.dart';
import 'package:application/Repositories/user_repository.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';

class RegisterController extends ChangeNotifier {
  final UserRepository userRepository;

  RegisterController({required this.userRepository});

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> register({
    required String username,
    required String name,
    required String surname,
    required String password,
    required DateTime birthDate,
  }) async {
    // Initialize state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Security: Check if a user with the same username already exists before proceeding
      // The username field in the database should also have a UNIQUE constraint
      final existingUser = await userRepository.getUserByUsername(username.trim());
      if (existingUser != null) {
        _errorMessage = "Username already taken.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Security: Hash the password with a strong salt (BCrypt default cost is 12)
      // We NEVER store plain text passwords in the database
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));

      // Sanitize and persist the new user
      await userRepository.createUser(UserCompanion.insert(
        username: username.trim(),
        name: name.trim(),
        surname: surname.trim(),
        password: hashedPassword,
        birthDate: birthDate,
      ));

      _isLoading = false;
      notifyListeners();
      return true; // Registration successful
    } catch (e) {
      // Handle unexpected database or hashing errors
      _errorMessage = "An error occurred during registration.";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
