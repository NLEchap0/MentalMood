import 'package:application/data/repositories/user_repository.dart';
import 'package:application/domain/models.dart';
import 'package:application/state/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthController authController;
  late MockUserRepository mockUserRepository;

  AppUser buildUser({
    int id = 1,
    String username = 'user',
    String name = 'N',
    String surname = 'S',
    String password = 'p',
  }) => AppUser(
    id: id,
    username: username,
    name: name,
    surname: surname,
    birthDate: DateTime(2000),
    passwordHash: password,
  );

  setUp(() {
    mockUserRepository = MockUserRepository();
    authController = AuthController(userRepository: mockUserRepository);
  });

  group('AuthController Session Tests', () {
    test('isLoggedIn false without a session', () async {
      expect(await authController.isLoggedIn(), false);
      expect(authController.currentUser, null);
    });

    test('startSession sets current user (cloud cache only)', () async {
      await authController.startSession(buildUser(id: 3, username: 'cloudy'));

      expect(authController.currentUser?.id, 3);
      expect(authController.currentUser?.username, 'cloudy');
      expect(await authController.isLoggedIn(), true);
    });

    test('logout clears current user', () async {
      await authController.startSession(buildUser(id: 1, username: 'user'));

      await authController.logout();

      expect(authController.currentUser, null);
      expect(await authController.isLoggedIn(), false);
    });
  });

  group('AuthController Profile Tests', () {
    test('updateProfile calls repository and updates local state', () async {
      await authController.startSession(
        buildUser(id: 1, username: 'user', name: 'Old', surname: 'Name'),
      );

      when(
        () => mockUserRepository.updateUser(
          id: any(named: 'id'),
          name: any(named: 'name'),
          surname: any(named: 'surname'),
          birthDate: any(named: 'birthDate'),
        ),
      ).thenAnswer((_) async => true);
      when(() => mockUserRepository.getUserByUsername('user')).thenAnswer(
        (_) async =>
            buildUser(id: 1, username: 'user', name: 'New', surname: 'Surname'),
      );

      final success = await authController.updateProfile(
        name: 'New',
        surname: 'Surname',
        birthDate: DateTime(1995),
      );

      expect(success, true);
      expect(authController.currentUser?.name, 'New');
      expect(authController.currentUser?.surname, 'Surname');
      verify(
        () => mockUserRepository.updateUser(
          id: any(named: 'id'),
          name: any(named: 'name'),
          surname: any(named: 'surname'),
          birthDate: any(named: 'birthDate'),
        ),
      ).called(1);
    });

    test('deleteAccount removes user and clears session', () async {
      await authController.startSession(buildUser(id: 1, username: 'user'));
      when(() => mockUserRepository.deleteUser(1)).thenAnswer((_) async => 1);

      final ok = await authController.deleteAccount();

      expect(ok, true);
      expect(authController.currentUser, null);
      verify(() => mockUserRepository.deleteUser(1)).called(1);
    });
  });
}
