import 'package:application/data/database/database.dart';
import 'package:application/data/database/mappers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Mappers', () {
    test('emotionToDomain maps tags and note', () {
      final row = EmotionData(
        id: 1,
        value: 7,
        userId: 2,
        createdAt: DateTime(2026, 8, 10),
        note: '  hello  ',
        tags: 'Work, Friends,',
      );

      final entry = emotionToDomain(row);

      expect(entry.id, 1);
      expect(entry.value, 7);
      expect(entry.note, '  hello  ');
      expect(entry.tags, ['Work', 'Friends']);
    });

    test('emotionToDomain handles null note and tags', () {
      final row = EmotionData(
        id: 2,
        value: 5,
        userId: 1,
        createdAt: DateTime(2026, 8, 10),
      );

      final entry = emotionToDomain(row);

      expect(entry.note, null);
      expect(entry.tags, isEmpty);
      expect(entry.hasNote, false);
    });

    test('emotionToCompanion joins tags and stores null when empty', () {
      final companion = emotionToCompanion(
        userId: 1,
        value: 6,
        note: 'ok',
        tags: const ['A', 'B'],
      );

      expect(companion.value.value, 6);
      expect(companion.tags.value, 'A,B');

      final empty = emotionToCompanion(userId: 1, value: 6);
      expect(empty.tags.value, null);
      expect(empty.note.value, null);
    });

    test('userToDomain maps row to AppUser', () {
      final row = UserData(
        id: 3,
        username: 'alice',
        name: 'Alice',
        surname: 'Smith',
        password: 'hash',
        birthDate: DateTime(1990),
      );

      final user = userToDomain(row);

      expect(user.id, 3);
      expect(user.username, 'alice');
      expect(user.passwordHash, 'hash');
      expect(user.fullName, 'Alice Smith');
    });

    test('userToCompanion builds insert companion', () {
      final companion = userToCompanion(
        username: 'bob',
        name: 'Bob',
        surname: 'Brown',
        password: 'hash',
        birthDate: DateTime(1991),
      );

      expect(companion.username.value, 'bob');
      expect(companion.password.value, 'hash');
    });
  });
}
