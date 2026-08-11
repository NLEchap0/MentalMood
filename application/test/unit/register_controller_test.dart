import 'package:application/data/repositories/user_repository.dart';
import 'package:application/domain/models.dart';
import 'package:application/state/register_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late RegisterController registerController;
  late MockUserRepository mockUserRepository;

  AppUser buildUser({int id = 1, String username = 'newuser'}) => AppUser(
    id: id,
    username: username,
    name: 'New',
    surname: 'User',
    birthDate: DateTime(2000, 1, 1),
    passwordHash: 'hashed',
  );

  setUp(() {
    mockUserRepository = MockUserRepository();
    registerController = RegisterController(userRepository: mockUserRepository);
  });

  group('RegisterController Tests', () {
    test('Registration success when username is available', () async {
      when(
        () => mockUserRepository.getUserByUsername('newuser'),
      ).thenAnswer((_) async => null);
      when(
        () => mockUserRepository.createUser(
          username: any(named: 'username'),
          name: any(named: 'name'),
          surname: any(named: 'surname'),
          password: any(named: 'password'),
          birthDate: any(named: 'birthDate'),
        ),
      ).thenAnswer((_) async => buildUser());

      final user = await registerController.register(
        username: 'newuser',
        name: 'New',
        surname: 'User',
        password: 'securePassword123',
        birthDate: DateTime(2000, 1, 1),
      );

      expect(user, isNotNull);
      expect(registerController.errorMessage, null);
      verify(
        () => mockUserRepository.createUser(
          username: any(named: 'username'),
          name: any(named: 'name'),
          surname: any(named: 'surname'),
          password: any(named: 'password'),
          birthDate: any(named: 'birthDate'),
        ),
      ).called(1);
    });

    test('Registration fails when username already taken', () async {
      when(
        () => mockUserRepository.getUserByUsername('existinguser'),
      ).thenAnswer((_) async => buildUser(username: 'existinguser'));

      final user = await registerController.register(
        username: 'existinguser',
        name: 'Test',
        surname: 'User',
        password: 'password',
        birthDate: DateTime.now(),
      );

      expect(user, null);
      expect(registerController.errorMessage, 'Username already taken.');
      verifyNever(
        () => mockUserRepository.createUser(
          username: any(named: 'username'),
          name: any(named: 'name'),
          surname: any(named: 'surname'),
          password: any(named: 'password'),
          birthDate: any(named: 'birthDate'),
        ),
      );
    });
  });
}
