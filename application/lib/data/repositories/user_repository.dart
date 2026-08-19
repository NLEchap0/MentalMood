import 'package:application/domain/models.dart';

/// Back-end contract for user data. Implementations own the storage details.
abstract class UserRepository {
  Future<AppUser?> getUserByUsername(String username);

  Future<AppUser> createUser({
    required String username,
    String? email,
    required String name,
    required String surname,
    required String password,
    required DateTime birthDate,
  });

  Future<bool> updateUser({
    required int id,
    required String name,
    required String surname,
    required DateTime birthDate,
    String? email,
  });

  Future<int> deleteUser(int userId);
}
