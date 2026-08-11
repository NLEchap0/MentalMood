import 'package:application/data/repositories/user_repository.dart';
import 'package:application/domain/models.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:drift/native.dart' show SqliteException;
import 'package:flutter/foundation.dart';

class RegisterController extends ChangeNotifier {
  final UserRepository userRepository;

  RegisterController({required this.userRepository});

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<AppUser?> register({
    required String username,
    required String name,
    required String surname,
    required String password,
    required DateTime birthDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final existing = await userRepository.getUserByUsername(username.trim());
      if (existing != null) {
        _errorMessage = 'Username already taken.';
        _finish();
        return null;
      }

      // BCrypt with cost 12: never store plain-text passwords.
      final hashed = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));

      final user = await userRepository.createUser(
        username: username.trim(),
        name: name.trim(),
        surname: surname.trim(),
        password: hashed,
        birthDate: birthDate,
      );

      _finish();
      return user;
    } on SqliteException catch (e) {
      // Unique constraint: same username registered concurrently.
      const uniqueViolationCodes = [
        2067,
        1555,
      ]; // SQLITE_CONSTRAINT_UNIQUE / PRIMARYKEY
      _errorMessage = uniqueViolationCodes.contains(e.resultCode)
          ? 'Username already taken.'
          : 'An error occurred during registration.';
    } catch (e) {
      debugPrint('Registration error: $e');
      _errorMessage = 'An error occurred during registration.';
    }

    _finish();
    return null;
  }

  void _finish() {
    _isLoading = false;
    notifyListeners();
  }
}
