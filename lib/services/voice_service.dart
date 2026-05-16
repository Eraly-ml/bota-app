import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';

/// ElevenLabs-powered voice playback for the KamBot mascot.
///
/// Replaces robotic `flutter_tts` with a high-quality multilingual voice.
/// Silently falls back to no-op when `ELEVENLABS_API_KEY` is missing or the
/// API call fails — preserves the `soundMuted` contract.
class VoiceService {
  // Voice "Bella" — warm, friendly, multilingual.
  static const String _voiceId = 'EXAVITQu4vr4xnSDxMaL';
  static const String _modelId = 'eleven_multilingual_v2';
  static const double _stability = 0.78;
  static const double _similarityBoost = 0.88;
  static const double _style = 0.28;

  static AudioPlayer? _playerInstance;
  static AudioPlayer get _player {
    _playerInstance ??= AudioPlayer();
    return _playerInstance!;
  }
  static String? _lastText;
  static bool _pending = false;

  /// Speak `text` aloud. Idempotent for repeated identical text.
  /// No-op when API key is absent or request fails.
  static Future<void> speak(String text) async {
    final clean = _stripEmojis(text);
    if (clean.isEmpty || _lastText == clean || _pending) return;
    _lastText = clean;
    _pending = true;
    try {
      final apiKey = dotenv.env['ELEVENLABS_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) return;
      final res = await http.post(
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$_voiceId'),
        headers: {
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: jsonEncode({
          'text': clean,
          'model_id': _modelId,
          'voice_settings': {
            'stability': _stability,
            'similarity_boost': _similarityBoost,
            'style': _style,
            'use_speaker_boost': true,
          },
        }),
      );
      if (res.statusCode != 200) return;
      await _player.stop();
      await _player.play(BytesSource(res.bodyBytes));
    } catch (_) {
      // silent fallback — keeps soundMuted semantics on any failure
    } finally {
      _pending = false;
    }
  }

  /// Stop any currently-playing audio and clear cache.
  static Future<void> stop() async {
    _lastText = null;
    try {
      await _player.stop();
    } catch (_) {}
  }

  /// Strip emojis & pictograph ranges so ElevenLabs doesn't read "smiling face".
  ///
  /// Dart [RegExp] does not support braced `\u{...}` syntax, so we filter
  /// runes by code-point ranges instead. Ranges cover Misc Symbols,
  /// Dingbats, Emoticons, Supplemental Symbols & Pictographs, plus the
  /// variation-selector block used in joined emoji sequences.
  static String _stripEmojis(String s) {
    final buf = StringBuffer();
    for (final r in s.runes) {
      final isEmoji =
          (r >= 0x1F000 && r <= 0x1FFFF) ||
          (r >= 0x2600 && r <= 0x27BF) ||
          (r >= 0xFE00 && r <= 0xFE0F);
      if (!isEmoji) buf.writeCharCode(r);
    }
    return buf.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
