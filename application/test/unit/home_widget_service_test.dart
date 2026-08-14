import 'package:application/services/home_widget_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHomeWidgetBridge extends Mock implements HomeWidgetBridge {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHomeWidgetBridge bridge;
  late HomeWidgetService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    bridge = MockHomeWidgetBridge();
    service = HomeWidgetService(
      bridge: bridge,
      now: () => DateTime.utc(2026, 1, 1, 12),
    );
  });

  group('HomeWidgetService', () {
    test('pushMood saves pref and pushes emoji', () async {
      when(() => bridge.updateMood(8, '😊')).thenAnswer((_) async {});
      await service.pushMood(userId: 1, value: 8);
      verify(() => bridge.updateMood(8, '😊')).called(1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('widget_mood'), contains('"value":8'));
    });

    test('pushMood maps value bands to emoji', () async {
      when(() => bridge.updateMood(any(), any())).thenAnswer((_) async {});
      await service.pushMood(userId: 1, value: 2);
      verify(() => bridge.updateMood(2, '😞')).called(1);
      await service.pushMood(userId: 1, value: 5);
      verify(() => bridge.updateMood(5, '😐')).called(1);
    });

    test('pushMood rejects out of range', () {
      expect(() => service.pushMood(userId: 1, value: 0), throwsArgumentError);
      expect(() => service.pushMood(userId: 1, value: 11), throwsArgumentError);
    });
  });
}
