import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Centralized bilingual string store loaded once from assets/data/locale.json.
///
/// Usage:
///   await LocaleStrings.load();              // call once at app start
///   LocaleStrings.setLanguage('ru' | 'kk');  // sync with GameProvider.isRussian
///   final s = LocaleStrings.t('parentTitle');
///   final s2 = LocaleStrings.t('childGreeting', params: {'name': 'Алия'});
///
/// Falls back gracefully:
///   - missing key  -> returns the key itself
///   - missing lang -> falls back to 'ru', then 'kk'
class LocaleStrings {
  static Map<String, Map<String, String>> _data = const {};
  static String _lang = 'ru';
  static bool _loaded = false;

  static bool get isLoaded => _loaded;
  static String get language => _lang;

  /// Loads the JSON dictionary into memory. Safe to call multiple times.
  static Future<void> load() async {
    if (_loaded) return;
    try {
      final raw = await rootBundle.loadString('assets/data/locale.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      _data = decoded.map(
        (lang, table) => MapEntry(
          lang,
          (table as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, v?.toString() ?? ''),
          ),
        ),
      );
      _loaded = true;
    } catch (_) {
      _data = const {};
      _loaded = false;
    }
  }

  /// Sync language with GameProvider.isRussian.
  /// `'ru'` for Russian, `'kk'` for Kazakh.
  static void setLanguage(String lang) {
    _lang = (lang == 'kk' || lang == 'ru') ? lang : 'ru';
  }

  /// Look up `key` in the current language. Substitutes `{name}`-style
  /// placeholders from [params]. Returns the key itself if no match.
  static String t(String key, {Map<String, String>? params}) {
    String? raw = _data[_lang]?[key];
    raw ??= _data['ru']?[key];
    raw ??= _data['kk']?[key];
    raw ??= key;
    if (params == null || params.isEmpty) return raw;
    var out = raw;
    params.forEach((k, v) {
      out = out.replaceAll('{$k}', v);
    });
    return out;
  }

  /// Look up by explicit language without changing the global setting.
  static String tFor(String lang, String key, {Map<String, String>? params}) {
    String? raw = _data[lang]?[key];
    raw ??= _data['ru']?[key];
    raw ??= _data['kk']?[key];
    raw ??= key;
    if (params == null || params.isEmpty) return raw;
    var out = raw;
    params.forEach((k, v) {
      out = out.replaceAll('{$k}', v);
    });
    return out;
  }
}
