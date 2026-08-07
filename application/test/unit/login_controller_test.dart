import 'package:application/DataBase/database.dart';
import 'package:application/Logic/login_controller.dart';
import 'package:application/Repositories/user_repository.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late LoginController loginController;
  late MockUserRepository mockUserRepository;

  setUpAll(() {
    registerFallbackValue(UserCompanion());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockUserRepository = MockUserRepository();
    loginController = LoginController(userRepository: mockUserRepository);
  });

  group('LoginController Auth Tests', () {
    test('Login success and saves to SharedPrefs', () async {
      const username = 'testuser';
      const password = 'password123';
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 10));

      final mockUser = UserData(
        id: 1, username: username, name: 'Test', surname: 'User',
        password: hashedPassword, birthDate: DateTime.now(),
      );

      when(() => mockUserRepository.getUserByUsername(username)).thenAnswer((_) async => mockUser);

      final result = await loginController.login(username, password);

      expect(result, true);
      expect(loginController.currentUser?.id, 1);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_session'), username);
    });

    test('isLoggedIn returns true if username in prefs', () async {
      const username = 'stored_user';
      SharedPreferences.setMockInitialValues({'user_session': username});
      
      final mockUser = UserData(
        id: 1, username: username, name: 'Stored', surname: 'User',
        password: 'hashed', birthDate: DateTime.now(),
      );

      when(() => mockUserRepository.getUserByUsername(username)).thenAnswer((_) async => mockUser);

      final loggedIn = await loginController.isLoggedIn();
      
      expect(loggedIn, true);
      expect(loginController.currentUser?.username, username);
    });

    test('Logout clears current user and prefs', () async {
      loginController.currentUser = UserData(
        id: 1, username: 'user', name: 'N', surname: 'S', password: 'p', birthDate: DateTime.now()
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_session', 'user');

      await loginController.logout();

      expect(loginController.currentUser, null);
      expect(prefs.getString('user_session'), null);
    });
  });

  group('LoginController Profile Tests', () {
    test('updateProfile calls repository and updates local state', () async {
      final initialUser = UserData(
        id: 1, username: 'user', name: 'Old', surname: 'Name', password: 'p', birthDate: DateTime(2000)
      );
      loginController.currentUser = initialUser;
      
      final newBirthDate = DateTime(1995);
      final updatedUser = initialUser.copyWith(name: 'New', surname: 'Surname', birthDate: newBirthDate);

      when(() => mockUserRepository.updateUser(any())).thenAnswer((_) async => true);
      when(() => mockUserRepository.getUserByUsername('user')).thenAnswer((_) async => updatedUser);

      final success = await loginController.updateProfile(
        name: 'New', surname: 'Surname', birthDate: newBirthDate
      );

      expect(success, true);
      expect(loginController.currentUser?.name, 'New');
      expect(loginController.currentUser?.surname, 'Surname');
      expect(loginController.currentUser?.birthDate, newBirthDate);
      
      verify(() => mockUserRepository.updateUser(any(
        that: isA<UserCompanion>().having((u) => u.name.value, 'name', 'New')
      ))).called(1);
    });
  });
}
