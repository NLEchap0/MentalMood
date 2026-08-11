import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// AI insights service (NVIDIA NIM compatible chat completion API).
/// NOTE: the API key is bundled with the app; use a server-side proxy
/// before shipping to production.
class AIService {
  AIService({String? apiKey, String? apiUrl, String? model})
    : _apiKey = apiKey ?? dotenv.maybeGet('NVIDIA_API_KEY') ?? '',
      _apiUrl = apiUrl ?? dotenv.maybeGet('NVIDIA_API_URL') ?? '',
      _model = model ?? dotenv.maybeGet('NVIDIA_MODEL') ?? '';

  final String _apiKey;
  final String _apiUrl;
  final String _model;

  bool get isConfigured =>
      _apiKey.isNotEmpty && _apiUrl.isNotEmpty && _model.isNotEmpty;

  Future<String?> getMoodInsights(String userPrompt) async {
    if (!isConfigured) {
      debugPrint('AI Service: not configured (missing env vars)');
      return null;
    }
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 2048,
          'temperature': 0.15,
          'top_p': 1.0,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        final message = choices.isNotEmpty
            ? (choices.first as Map<String, dynamic>)['message']
            : null;
        return message == null
            ? null
            : (message as Map<String, dynamic>)['content'] as String?;
      }
      debugPrint('AI Error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      debugPrint('AI Exception: $e');
      return null;
    }
  }
}
