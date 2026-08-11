import 'package:application/data/database/database.dart';
import 'package:application/data/database/mappers.dart';
import 'package:application/data/repositories/user_repository.dart';
import 'package:application/domain/models.dart';
import 'package:drift/drift.dart';

class DriftUserRepository implements UserRepository {
  final AppDataBase _db;

  DriftUserRepository(this._db);

  @override
  Future<AppUser?> getUserByUsername(String username) async {
    final row = await _db.getUser(username);
    return row == null ? null : userToDomain(row);
  }

  @override
  Future<AppUser> createUser({
    required String username,
    required String name,
    required String surname,
    required String password,
    required DateTime birthDate,
  }) async {
    final id = await _db.createUser(
      userToCompanion(
        username: username,
        name: name,
        surname: surname,
        password: password,
        birthDate: birthDate,
      ),
    );
    return AppUser(
      id: id,
      username: username,
      name: name,
      surname: surname,
      birthDate: birthDate,
      passwordHash: password,
    );
  }

  @override
  Future<bool> updateUser({
    required int id,
    required String name,
    required String surname,
    required DateTime birthDate,
  }) {
    return _db.updateUser(
      id,
      UserCompanion(
        name: Value(name),
        surname: Value(surname),
        birthDate: Value(birthDate),
      ),
    );
  }

  @override
  Future<int> deleteUser(int userId) => _db.deleteUser(userId);
}
