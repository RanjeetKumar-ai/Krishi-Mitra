import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/localization/tts_service.dart';
import '../../../services/localization/tts_languages.dart';

Future<void> showTtsLanguageSheet(BuildContext context) async {
  final tts = TtsService.instance;

  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Voice language",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            _LangItem(
              title: "English",
              selected: tts.currentLanguage == TtsLanguages.enIN,
              onTap: () async {
                HapticFeedback.selectionClick();
                await tts.setLanguage(TtsLanguages.enIN);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _LangItem(
              title: "हिन्दी",
              subtitle: "फोन में हिन्दी voice install होना चाहिए",
              selected: tts.currentLanguage == TtsLanguages.hiIN,
              onTap: () async {
                HapticFeedback.selectionClick();
                await tts.setLanguage(TtsLanguages.hiIN, allowFallback: true);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

class _LangItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LangItem({
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? const Color(0xFF2E7D32) : Colors.black12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ]
                ],
              ),
            ),
            Icon(selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? const Color(0xFF2E7D32) : Colors.black38),
          ],
        ),
      ),
    );
  }
}
