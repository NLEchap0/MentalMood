import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AIService {
  final String _apiKey = dotenv.get('NVIDIA_API_KEY');
  final String _apiUrl = dotenv.get('NVIDIA_API_URL');
  final String _model = dotenv.get('NVIDIA_MODEL');

  /// Future implementation to get AI insights based on mood history
  Future<String?> getMoodInsights(String userPrompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "model": _model,
          "messages": [
            {"role": "user", "content": userPrompt}
          ],
          "max_tokens": 2048,
          "temperature": 0.15,
          "top_p": 1.0,
          "stream": false
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        debugPrint('AI Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('AI Exception: $e');
      return null;
    }
  }
}
