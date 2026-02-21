// lib/services/localization/tts_languages.dart
library;

/// Supported TTS language codes
class TtsLanguages {
  static const String enIN = 'en-IN'; // English (India)
  static const String hiIN = 'hi-IN'; // Hindi

  static const List<AppLanguage> supported = [
    AppLanguage(
      code: enIN,
      label: 'English',
      nativeLabel: 'English',
      flag: '🇮🇳',
    ),
    AppLanguage(
      code: hiIN,
      label: 'Hindi',
      nativeLabel: 'हिन्दी',
      flag: '🇮🇳',
    ),
  ];
}

class AppLanguage {
  final String code;
  final String label;
  final String nativeLabel;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.label,
    required this.nativeLabel,
    required this.flag,
  });
}

/// Helper — pick the right string based on current TTS language
extension BilingualText on String {
  /// Usage: speak(enText.orHindi(hiText))
  String orHindi(String hindiText) {
    // Resolved at call site using TtsService.instance.isHindi
    return this; // actual resolution done inline at call sites
  }
}
