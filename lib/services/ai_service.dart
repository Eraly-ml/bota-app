import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gemini powered chat service for the KamBot mascot.
class AiService {
  static Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gemini_api_key') ?? 'AIzaSyCgRDbyjoc3h2oDON3k1UJXhagOYM1hpyI';
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
    
    final contents = <Map<String, dynamic>>[];

    for (final msg in history) {
      contents.add({
        'role': msg['role'] == 'assistant' ? 'model' : 'user',
        'parts': [{'text': msg['content'] ?? ''}],
      });
    }

    contents.add({
      'role': 'user',
      'parts': [{'text': userMessage}],
    });

    final body = json.encode({
      'systemInstruction': {
        'parts': [{'text': _systemPrompt}]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 300,
      }
    });

    final apiKey = await _getApiKey();
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        return text ?? 'Извини, я не смог ответить. Попробуй ещё раз!';
      } else if (response.statusCode == 400) {
        return 'Ошибка запроса. Возможно, ключ недействителен или превышен лимит!';
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
