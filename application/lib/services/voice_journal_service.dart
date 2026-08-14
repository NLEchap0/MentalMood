import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class VoiceNote {
  const VoiceNote({required this.text, required this.createdAt});

  factory VoiceNote.fromJson(Map<String, dynamic> json) {
    return VoiceNote(
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }

  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'text': text,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}

abstract class SpeechBridge {
  Future<String> transcribe(String audioPath);
}

class VoiceJournalService {
  VoiceJournalService({required this._bridge});

  final SpeechBridge _bridge;

  Future<String> transcribeNote({
    required int userId,
    required String audioPath,
  }) async {
    final text = await _bridge.transcribe(audioPath);
    final note = VoiceNote(text: text, createdAt: DateTime.now().toUtc());
    final current = await history(userId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'voice_notes_$userId',
      jsonEncode([...current, note].map((n) => n.toJson()).toList()),
    );
    return text;
  }

  Future<List<VoiceNote>> history(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('voice_notes_$userId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => VoiceNote.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
