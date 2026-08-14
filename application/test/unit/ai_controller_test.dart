import 'package:application/services/ai_api_client.dart';
import 'package:application/services/ai_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAiApiClient extends Mock implements AiApiClient {}

void main() {
  late MockAiApiClient api;
  late AiController controller;

  setUp(() {
    api = MockAiApiClient();
    controller = AiController(apiClient: api);
  });

  group('AiController', () {
    test('sendChat success sets reply and state', () async {
      when(() => api.chat(
        baseUrl: any(named: 'baseUrl'),
        accessToken: any(named: 'accessToken'),
        message: any(named: 'message'),
      )).thenAnswer((_) async => 'Ciao!');
      final ok = await controller.sendChat(
        baseUrl: 'http://test.local',
        accessToken: 't',
        message: 'ciao',
      );
      expect(ok, true);
      expect(controller.lastReply, 'Ciao!');
      expect(controller.state, AiState.success);
    });

    test('sendChat maps 402 to paymentRequired', () async {
      when(() => api.chat(
        baseUrl: any(named: 'baseUrl'),
        accessToken: any(named: 'accessToken'),
        message: any(named: 'message'),
      )).thenThrow(const AiFailure(
        statusCode: 402,
        code: 'payment_required',
        message: 'pro_required',
      ));
      final ok = await controller.sendChat(
        baseUrl: 'http://test.local',
        accessToken: 't',
        message: 'x',
      );
      expect(ok, false);
      expect(controller.state, AiState.paymentRequired);
    });

    test('sendChat maps consent_required 401', () async {
      when(() => api.chat(
        baseUrl: any(named: 'baseUrl'),
        accessToken: any(named: 'accessToken'),
        message: any(named: 'message'),
      )).thenThrow(const AiFailure(
        statusCode: 401,
        code: 'consent_required',
        message: 'consent_required',
      ));
      await controller.sendChat(
        baseUrl: 'http://test.local',
        accessToken: 't',
        message: 'x',
      );
      expect(controller.state, AiState.consentRequired);
    });

    test('enableConsent sets hasConsent', () async {
      when(() => api.setConsent(
        baseUrl: any(named: 'baseUrl'),
        accessToken: any(named: 'accessToken'),
        consent: any(named: 'consent'),
      )).thenAnswer((_) async => true);
      final ok = await controller.enableConsent(
        baseUrl: 'http://test.local',
        accessToken: 't',
      );
      expect(ok, true);
      expect(controller.hasConsent, true);
    });

    test('revokeConsent clears state and reply', () async {
      when(() => api.setConsent(
        baseUrl: any(named: 'baseUrl'),
        accessToken: any(named: 'accessToken'),
        consent: any(named: 'consent'),
      )).thenAnswer((_) async => false);
      controller.lastReplyForTest = 'old reply';
      final ok = await controller.revokeConsent(
        baseUrl: 'http://test.local',
        accessToken: 't',
      );
      expect(ok, true);
      expect(controller.hasConsent, false);
      expect(controller.lastReply, null);
    });

    test('loadInsights populates list', () async {
      when(() => api.insights(
        baseUrl: any(named: 'baseUrl'),
        accessToken: any(named: 'accessToken'),
      )).thenAnswer((_) async => [
        AiInsight(
          kind: 'weekly',
          content: 'Trend',
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      ]);
      await controller.loadInsights(
        baseUrl: 'http://test.local',
        accessToken: 't',
      );
      expect(controller.insights.length, 1);
    });
  });
}
