import 'package:application/services/questionnaire_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('severityFromScore', () {
    test('PHQ-9 severity bands', () {
      expect(QuestionnaireService.severityFromScore('phq9', 0), 'minimal');
      expect(QuestionnaireService.severityFromScore('phq9', 7), 'mild');
      expect(QuestionnaireService.severityFromScore('phq9', 12), 'moderate');
      expect(QuestionnaireService.severityFromScore('phq9', 17), 'moderately severe');
      expect(QuestionnaireService.severityFromScore('phq9', 25), 'severe');
    });

    test('GAD-7 severity bands', () {
      expect(QuestionnaireService.severityFromScore('gad7', 0), 'minimal');
      expect(QuestionnaireService.severityFromScore('gad7', 7), 'mild');
      expect(QuestionnaireService.severityFromScore('gad7', 12), 'moderate');
      expect(QuestionnaireService.severityFromScore('gad7', 17), 'severe');
    });

    test('throws on unknown type', () {
      expect(
        () => QuestionnaireService.severityFromScore('unknown', 5),
        throwsArgumentError,
      );
    });
  });

  group('QuestionnaireService save/history', () {
    test('save computes score and appends history', () async {
      final svc = QuestionnaireService();
      final r = await svc.save(
        userId: 3,
        type: 'phq9',
        answers: List.filled(9, 2),
      );
      expect(r.type, 'phq9');
      expect(r.totalScore, 18);
      expect(r.severity, 'moderately severe');
      expect(r.completedAt.isUtc, true);

      final history = await svc.history(3);
      expect(history.length, 1);
      expect(history.first.totalScore, 18);
    });

    test('save validates answer count', () async {
      final svc = QuestionnaireService();
      expect(
        () => svc.save(userId: 3, type: 'phq9', answers: [1, 2]),
        throwsArgumentError,
      );
      expect(
        () => svc.save(userId: 3, type: 'gad7', answers: List.filled(9, 1)),
        throwsArgumentError,
      );
    });

    test('history is per-user', () async {
      final svc = QuestionnaireService();
      await svc.save(userId: 1, type: 'gad7', answers: List.filled(7, 1));
      expect((await svc.history(1)).length, 1);
      expect((await svc.history(2)).length, 0);
    });
  });
}
