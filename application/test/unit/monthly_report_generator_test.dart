import 'dart:io';
import 'dart:typed_data';

import 'package:application/data/repositories/emotion_repository.dart';
import 'package:application/domain/models.dart';
import 'package:application/services/monthly_report_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEmotionRepository extends Mock implements EmotionRepository {}

class TempFileWriter implements ReportFileWriter {
  @override
  Future<File> write(Uint8List bytes, String name) async {
    final f = File('${Directory.systemTemp.path}/$name');
    await f.writeAsBytes(bytes);
    return f;
  }
}

void main() {
  late MockEmotionRepository repo;
  late MonthlyReportGenerator generator;

  setUp(() {
    repo = MockEmotionRepository();
    generator = MonthlyReportGenerator(
      emotions: repo,
      fileWriter: TempFileWriter(),
      now: () => DateTime.utc(2026, 1, 15),
    );
  });

  group('MonthlyReportGenerator', () {
    test('generate with no entries produces valid PDF', () async {
      when(() => repo.getEmotionsForUser(1)).thenAnswer((_) async => []);
      final bytes = await generator.generate(userId: 1, year: 2026, month: 1);
      expect(bytes.length, greaterThan(100));
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('generate computes stats from entries', () async {
      when(() => repo.getEmotionsForUser(1)).thenAnswer((_) async => [
        MoodEntry(id: 1, value: 8, userId: 1, createdAt: DateTime.utc(2026, 1, 2)),
        MoodEntry(id: 2, value: 3, userId: 1, createdAt: DateTime.utc(2026, 1, 5)),
        MoodEntry(id: 3, value: 6, userId: 1, createdAt: DateTime.utc(2026, 1, 8)),
        // fuori mese: non deve contare
        MoodEntry(id: 4, value: 10, userId: 1, createdAt: DateTime.utc(2026, 2, 1)),
      ]);
      final bytes = await generator.generate(userId: 1, year: 2026, month: 1);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('saveToTemp writes a real file', () async {
      final file = await generator.saveToTemp(
        Uint8List.fromList(List.filled(50, 7)),
        'test-report.pdf',
      );
      expect(await file.exists(), true);
      expect(await file.length(), 50);
    });
  });
}
