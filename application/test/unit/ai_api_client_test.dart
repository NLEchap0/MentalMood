import 'package:application/services/ai_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('HttpAiApiClient', () {
    test('chat posts to /ai/chat and returns reply', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response('{"reply":"Ciao!"}', 200);
      });
      final api = HttpAiApiClient(client: client);
      final reply = await api.chat(
        baseUrl: 'http://test.local',
        accessToken: 'tok',
        message: 'ciao',
      );
      expect(reply, 'Ciao!');
      expect(captured.url.toString(), 'http://test.local/ai/chat');
      expect(captured.headers['Authorization'], 'Bearer tok');
    });

    test('chat maps 402 to AiFailure payment_required', () async {
      final client = MockClient((_) async => http.Response(
        '{"error":{"code":"payment_required","message":"pro_required"}}',
        402,
      ));
      final api = HttpAiApiClient(client: client);
      expect(
        () => api.chat(
          baseUrl: 'http://test.local',
          accessToken: 't',
          message: 'x',
        ),
        throwsA(isA<AiFailure>()
            .having((e) => e.statusCode, 'statusCode', 402)
            .having((e) => e.code, 'code', 'payment_required')),
      );
    });

    test('setConsent posts consent and returns true', () async {
      final client = MockClient((_) async =>
          http.Response('{"consent":true,"deleted":0}', 200));
      final api = HttpAiApiClient(client: client);
      expect(
        await api.setConsent(
          baseUrl: 'http://test.local',
          accessToken: 't',
          consent: true,
        ),
        true,
      );
    });

    test('revokeAiData returns deleted count', () async {
      final client = MockClient((_) async =>
          http.Response('{"consent":false,"deleted":3}', 200));
      final api = HttpAiApiClient(client: client);
      expect(
        await api.revokeAiData(baseUrl: 'http://test.local', accessToken: 't'),
        3,
      );
    });

    test('insights parses list', () async {
      final client = MockClient((_) async => http.Response(
        '{"insights":[{"kind":"weekly","content":"Trend","created_at":"2026-01-01T10:00:00Z"}]}',
        200,
      ));
      final api = HttpAiApiClient(client: client);
      final list = await api.insights(
        baseUrl: 'http://test.local',
        accessToken: 't',
      );
      expect(list.length, 1);
      expect(list.first.kind, 'weekly');
      expect(list.first.content, 'Trend');
    });

    test('network error maps to AiFailure(0, network_error)', () async {
      final client = MockClient((_) async => throw Exception('boom'));
      final api = HttpAiApiClient(client: client);
      expect(
        () => api.chat(
          baseUrl: 'http://test.local',
          accessToken: 't',
          message: 'x',
        ),
        throwsA(isA<AiFailure>()
            .having((e) => e.statusCode, 'statusCode', 0)
            .having((e) => e.code, 'code', 'network_error')),
      );
    });
  });
}
