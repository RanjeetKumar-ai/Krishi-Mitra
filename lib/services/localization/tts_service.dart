import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'tts_languages.dart';

/// One shared TTS instance for the whole app:
/// - prevents overlap, supports Stop/Listen UI
/// - works offline using Android native TTS voices (if installed on device)
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _inited = false;

  final ValueNotifier<bool> isSpeaking = ValueNotifier(false);

  String _lang = TtsLanguages.enIN;
  String get currentLanguage => _lang;

  Future<void> init({String language = TtsLanguages.enIN}) async {
    if (_inited) return;
    _inited = true;

    await _tts.setSharedInstance(true);
    if (!kIsWeb && Platform.isAndroid) {
      await _tts.setAudioAttributesForNavigation();
    }

    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() => isSpeaking.value = true);
    _tts.setCompletionHandler(() => isSpeaking.value = false);
    _tts.setCancelHandler(() => isSpeaking.value = false);
    _tts.setErrorHandler((_) => isSpeaking.value = false);

    await setLanguage(language, allowFallback: true);
  }

  Future<bool?> isLanguageInstalled(String code) async {
    if (!kIsWeb && Platform.isAndroid) {
      final res = await _tts.isLanguageInstalled(code);
      return res is bool ? res : null;
    }
    return null;
  }

  Future<void> setLanguage(String code, {bool allowFallback = false}) async {
    if (allowFallback && !kIsWeb && Platform.isAndroid) {
      final installed = await isLanguageInstalled(code);
      if (installed == false) {
        _lang = TtsLanguages.enIN;
        await _tts.setLanguage(_lang);
        return;
      }
    }
    _lang = code;
    await _tts.setLanguage(code);
  }

  Future<void> speak(String text, {String? languageCode}) async {
    final msg = text.trim();
    if (msg.isEmpty) return;

    await _tts.stop();

    final targetLang = languageCode ?? _lang;
    if (targetLang != _lang) {
      await setLanguage(targetLang, allowFallback: true);
    }

    await _tts.speak(msg);
  }

  Future<void> stop() async => _tts.stop();
}
