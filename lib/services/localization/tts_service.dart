// lib/services/localization/tts_service.dart
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'tts_languages.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();

  String _currentLanguage = TtsLanguages.enIN;
  String get currentLanguage => _currentLanguage;

  /// The ID of the widget that is currently speaking.
  /// Every widget checks this to know if IT is the active speaker.
  final ValueNotifier<String?> currentSpeakId = ValueNotifier(null);

  /// Global speaking state — true when any TTS is active
  final ValueNotifier<bool> isSpeaking = ValueNotifier(false);

  Future<void> init() async {
    await _tts.setLanguage(_currentLanguage);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => isSpeaking.value = true);
    _tts.setCompletionHandler(() {
      isSpeaking.value = false;
      currentSpeakId.value = null;
    });
    _tts.setCancelHandler(() {
      isSpeaking.value = false;
      currentSpeakId.value = null;
    });
    _tts.setErrorHandler((_) {
      isSpeaking.value = false;
      currentSpeakId.value = null;
    });
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await _tts.setLanguage(languageCode);
  }

  /// Speak with an optional [speakId] — only the widget with this ID
  /// will show as "active". Stops any previous speech first.
  Future<void> speak(String text,
      {String? languageCode, String? speakId}) async {
    await stop();
    if (languageCode != null && languageCode != _currentLanguage) {
      await _tts.setLanguage(languageCode);
    } else {
      await _tts.setLanguage(_currentLanguage);
    }
    currentSpeakId.value = speakId;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    isSpeaking.value = false;
    currentSpeakId.value = null;
  }

  bool get isHindi => _currentLanguage == TtsLanguages.hiIN;
}
