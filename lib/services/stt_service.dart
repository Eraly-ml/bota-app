import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Speech-to-text wrapper for voice input in the AI chat.
///
/// Handles microphone permission, listening lifecycle, and
/// graceful fallback when STT is unavailable.
class SttService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool _initialized = false;

  /// Whether the service is currently listening.
  static bool get isListening => _speech.isListening;

  /// Whether STT is available on this device.
  static Future<bool> get isAvailable async {
    if (!_initialized) {
      _initialized = await _speech.initialize(
        onError: (_) {},
        onStatus: (_) {},
      );
    }
    return _initialized && _speech.isAvailable;
  }

  /// Start listening and stream recognized words.
  ///
  /// [onResult] is called with the full recognized text so far.
  /// [onDone] is called when listening stops (user stops or timeout).
  /// [localeId] can be 'kk_KZ' or 'ru_RU' to hint the recognizer.
  static Future<void> startListening({
    required void Function(String text) onResult,
    required void Function() onDone,
    String localeId = 'ru_RU',
  }) async {
    if (!await isAvailable) return;

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onDone();
        }
      },
      localeId: localeId,
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  /// Stop listening manually.
  static Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}
