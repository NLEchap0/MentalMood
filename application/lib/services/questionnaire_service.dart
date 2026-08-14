import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class QuestionnaireResult {
  const QuestionnaireResult({
    required this.type,
    required this.completedAt,
    required this.totalScore,
    required this.severity,
  });

  factory QuestionnaireResult.fromJson(Map<String, dynamic> json) {
    return QuestionnaireResult(
      type: json['type'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String).toUtc(),
      totalScore: (json['total_score'] as num).toInt(),
      severity: json['severity'] as String,
    );
  }

  final String type;
  final DateTime completedAt;
  final int totalScore;
  final String severity;

  Map<String, dynamic> toJson() => {
        'type': type,
        'completed_at': completedAt.toUtc().toIso8601String(),
        'total_score': totalScore,
        'severity': severity,
      };
}

class QuestionnaireService {
  static const _maxHistory = 50;

  static String severityFromScore(String type, int score) {
    if (type == 'phq9') {
      if (score <= 4) return 'minimal';
      if (score <= 9) return 'mild';
      if (score <= 14) return 'moderate';
      if (score <= 19) return 'moderately severe';
      return 'severe';
    }
    if (type == 'gad7') {
      if (score <= 4) return 'minimal';
      if (score <= 9) return 'mild';
      if (score <= 14) return 'moderate';
      return 'severe';
    }
    throw ArgumentError.value(type, 'type', 'unknown questionnaire type');
  }

  Future<List<QuestionnaireResult>> history(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('questionnaires_$userId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => QuestionnaireResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<QuestionnaireResult> save({
    required int userId,
    required String type,
    required List<int> answers,
  }) async {
    final expected = type == 'phq9'
        ? 9
        : type == 'gad7'
            ? 7
            : throw ArgumentError.value(type, 'type', 'unknown type');
    if (answers.length != expected) {
      throw ArgumentError('$type requires $expected answers, got ${answers.length}');
    }
    final total = answers.fold<int>(0, (a, b) => a + b);
    final result = QuestionnaireResult(
      type: type,
      completedAt: DateTime.now().toUtc(),
      totalScore: total,
      severity: severityFromScore(type, total),
    );

    final current = await history(userId);
    final updated = [...current, result];
    final trimmed = updated.length > _maxHistory
        ? updated.sublist(updated.length - _maxHistory)
        : updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'questionnaires_$userId',
      jsonEncode(trimmed.map((r) => r.toJson()).toList()),
    );
    return result;
  }
}
