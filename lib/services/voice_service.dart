import 'package:flutter_tts/flutter_tts.dart';

/// FlutterTTS-powered voice playback for the KamBot mascot.
/// Free and works without API keys.
class VoiceService {
  static FlutterTts? _ttsInstance;
  static FlutterTts get _tts {
    _ttsInstance ??= FlutterTts();
    return _ttsInstance!;
  }

  static String? _lastText;
  static bool _pending = false;

  /// Speak `text` aloud.
  static Future<void> speak(String text) async {
    final clean = _stripEmojis(text);
    if (clean.isEmpty || _lastText == clean || _pending) return;
    _lastText = clean;
    _pending = true;

    try {
      await _tts.setLanguage("ru-RU"); // Default to Russian
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      
      await _tts.speak(clean);
    } catch (e) {
      print('TTS Error: $e');
    } finally {
      _pending = false;
    }
  }

  /// Stop any currently-playing audio and clear cache.
  static Future<void> stop() async {
    _lastText = null;
    try {
      await _tts.stop();
    } catch (_) {}
    _pending = false;
  }

  /// Strip emojis & pictograph ranges so TTS doesn't read them weirdly.
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
