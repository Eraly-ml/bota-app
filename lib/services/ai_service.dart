import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// DeepSeek powered chat service for the KamBot mascot.
class AiService {
  static Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    // Try to get from prefs first, then from .env, then fallback
    return prefs.getString('deepseek_api_key') ?? 
           dotenv.env['DEEPSEEK_API_KEY'] ?? 
           'YOUR_DEEPSEEK_API_KEY';
  }
  
  static const String _systemPrompt =
      'Ты - Бота, добрый и умный верблюжонок-помощник для детей 6-10 лет. '
      'Ты помогаешь детям узнавать интересные факты о Казахстане, его культуре, природе и истории. '
      'Отвечай коротко, понятно и дружелюбно. Используй простые слова. '
      'Если ребенок спрашивает про викторину - помоги разобраться в теме, но не давай прямые ответы на вопросы викторины. '
      'Можешь отвечать на казахском или русском языке, в зависимости от языка вопроса. '
      'Не используй эмодзи в ответах. Будь позитивным и поддерживающим.';

  static Future<String> sendMessage(
      String userMessage, List<Map<String, String>> history) async {
    
    final messages = <Map<String, String>>[];

    // Add system prompt
    messages.add({'role': 'system', 'content': _systemPrompt});

    // Add history
    for (final msg in history) {
      messages.add({
        'role': msg['role'] == 'assistant' ? 'assistant' : 'user',
        'content': msg['content'] ?? '',
      });
    }

    // Add current message
    messages.add({'role': 'user', 'content': userMessage});

    final body = json.encode({
      'model': 'deepseek-v4-flash',
      'messages': messages,
      'temperature': 0.7,
      'max_tokens': 300,
      'thinking': {'type': 'disabled'}, // Disable thinking mode for speed
    });

    final apiKey = await _getApiKey();
    final url = 'https://api.deepseek.com/chat/completions';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['choices']?[0]?['message']?['content'] as String?;
        return text ?? 'Извини, я не смог ответить. Попробуй ещё раз!';
      } else if (response.statusCode == 401) {
        return 'Ошибка авторизации. Проверь свой API ключ DeepSeek!';
      } else {
        return 'Сервер ответил с ошибкой ${response.statusCode}. Попробуй позже!';
      }
    } on TimeoutException {
      return 'Запрос занял слишком много времени. Проверь интернет и попробуй снова!';
    } on SocketException catch (e) {
      return 'Нет подключения к серверу (${e.message}). Проверь интернет!';
    } catch (e) {
      return 'Ошибка: ${e.runtimeType}. Попробуй снова!';
    }
  }
}
