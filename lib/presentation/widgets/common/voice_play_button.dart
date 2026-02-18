import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/localization/tts_service.dart';

class VoicePlayButton extends StatelessWidget {
  final String speakText;
  final String? languageCode;

  const VoicePlayButton({
    super.key,
    required this.speakText,
    this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final tts = TtsService.instance;

    return ValueListenableBuilder<bool>(
      valueListenable: tts.isSpeaking,
      builder: (_, speaking, __) {
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () async {
            HapticFeedback.lightImpact();
            if (speaking) {
              await tts.stop();
            } else {
              await tts.speak(speakText, languageCode: languageCode);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  speaking ? Icons.stop_circle_outlined : Icons.volume_up,
                  size: 16,
                  color: const Color(0xFF2E7D32),
                ),
                const SizedBox(width: 6),
                Text(
                  speaking ? "Stop" : "Listen",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
