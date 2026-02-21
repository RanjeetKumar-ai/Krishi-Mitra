// lib/features/common/voice_play_button.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/localization/tts_service.dart';

/// A self-contained play/stop voice button.
///
/// Each instance has a unique [speakId] so only the tapped card shows
/// as "speaking" — no cross-card bleed.
class VoicePlayButton extends StatelessWidget {
  /// The text to speak when tapped.
  final String speakText;

  /// Unique identifier for this button instance.
  /// Defaults to the speakText itself, but pass an explicit ID
  /// (e.g. task.id) to guarantee uniqueness.
  final String? speakId;

  /// Icon size. Defaults to 20.
  final double iconSize;

  /// Container size. Defaults to 32.
  final double size;

  const VoicePlayButton({
    super.key,
    required this.speakText,
    this.speakId,
    this.iconSize = 20,
    this.size = 32,
  });

  String get _id => speakId ?? speakText;

  @override
  Widget build(BuildContext context) {
    // Listen to currentSpeakId — only rebuild THIS widget when its
    // ownership changes, not when any other widget speaks.
    return ValueListenableBuilder<String?>(
      valueListenable: TtsService.instance.currentSpeakId,
      builder: (context, activeId, _) {
        final isThisSpeaking = activeId == _id;

        return GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            if (isThisSpeaking) {
              await TtsService.instance.stop();
            } else {
              await TtsService.instance.speak(
                speakText,
                speakId: _id,
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isThisSpeaking
                  ? AppColors.primaryGreen.withValues(alpha: (0.15))
                  : AppColors.primaryGreen.withValues(alpha: (0.08)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isThisSpeaking
                    ? AppColors.primaryGreen
                    : AppColors.primaryGreen.withValues(alpha: (0.3)),
                width: isThisSpeaking ? 1.8 : 1.2,
              ),
            ),
            child: Center(
              child: Icon(
                isThisSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                size: iconSize,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        );
      },
    );
  }
}
