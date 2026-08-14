import 'package:application/services/voice_journal_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSpeechBridge extends Mock implements SpeechBridge {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSpeechBridge bridge;
  late VoiceJournalService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    bridge = MockSpeechBridge();
    service = VoiceJournalService(bridge: bridge);
  });

  group('VoiceJournalService', () {
    test('transcribeNote returns text and saves history', () async {
      when(() => bridge.transcribe('audio.m4a')).thenAnswer((_) async => 'Oggi mi sento bene');
      final text = await service.transcribeNote(userId: 2, audioPath: 'audio.m4a');
      expect(text, 'Oggi mi sento bene');
      final history = await service.history(2);
      expect(history.length, 1);
      expect(history.first.text, 'Oggi mi sento bene');
    });

    test('history is per-user', () async {
      when(() => bridge.transcribe(any())).thenAnswer((_) async => 'nota');
      await service.transcribeNote(userId: 1, audioPath: 'a.m4a');
      expect((await service.history(1)).length, 1);
      expect((await service.history(3)).length, 0);
    });
  });
}
