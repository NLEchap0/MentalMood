import 'package:application/data/repositories/user_repository.dart';
import 'package:application/domain/models.dart';
import 'package:application/state/auth_controller.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences.setMockInitialValues({});
    mockUserRepository = MockUserRepository();
    authController = AuthController(userRepository: mockUserRepository);
  });

  group('AuthController Auth Tests', () {
    test('Login success and saves to SharedPrefs', () async {
      const username = 'testuser';
      const password = 'password123';
      final hashedPassword = BCrypt.hashpw(
        password,
        BCrypt.gensalt(logRounds: 10),
      );

      when(() => mockUserRepository.getUserByUsername(username)).thenAnswer(
        (_) async =>
            buildUser(id: 1, username: username, password: hashedPassword),
      );

      final result = await authController.login(username, password);

      expect(result, true);
      expect(authController.currentUser?.id, 1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_session'), username);
    });

    test('Login fails on wrong password', () async {
      const username = 'testuser';
      final validHash = BCrypt.hashpw(
        'right-password',
        BCrypt.gensalt(logRounds: 10),
      );
      when(() => mockUserRepository.getUserByUsername(username)).thenAnswer(
        (_) async => buildUser(username: username, password: validHash),
      );

      final result = await authController.login(username, 'wrong-password');

      expect(result, false);
      expect(authController.errorMessage, 'Invalid username or password.');
    });

    test('isLoggedIn returns true if username in prefs', () async {
      const username = 'stored_user';
      SharedPreferences.setMockInitialValues({'user_session': username});

      when(
        () => mockUserRepository.getUserByUsername(username),
      ).thenAnswer((_) async => buildUser(username: username));

      final loggedIn = await authController.isLoggedIn();

      expect(loggedIn, true);
      expect(authController.currentUser?.username, username);
    });

    test('Logout clears current user and prefs', () async {
      SharedPreferences.setMockInitialValues({'user_session': 'user'});
      when(
        () => mockUserRepository.getUserByUsername('user'),
      ).thenAnswer((_) async => buildUser(username: 'user'));
      await authController.isLoggedIn();

      await authController.logout();

      expect(authController.currentUser, null);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_session'), null);
    });

    test('startSession persists a freshly registered user', () async {
      await authController.startSession(buildUser(id: 2, username: 'newbie'));

      expect(authController.currentUser?.id, 2);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_session'), 'newbie');
    });
  });

  group('AuthController Profile Tests', () {
    test('updateProfile calls repository and updates local state', () async {
      SharedPreferences.setMockInitialValues({'user_session': 'user'});
      when(() => mockUserRepository.getUserByUsername('user')).thenAnswer(
        (_) async => buildUser(username: 'user', name: 'Old', surname: 'Name'),
      );
      await authController.isLoggedIn();

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
            buildUser(username: 'user', name: 'New', surname: 'Surname'),
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
  });
}
