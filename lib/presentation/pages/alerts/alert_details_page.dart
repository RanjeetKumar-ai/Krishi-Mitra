library;

import '../../../services/localization/tts_service.dart';
import '../../../services/localization/tts_languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/alert_model.dart';

class AlertDetailsPage extends StatefulWidget {
  final AlertModel alert;

  const AlertDetailsPage({super.key, required this.alert});

  @override
  State<AlertDetailsPage> createState() => _AlertDetailsPageState();
}

class _AlertDetailsPageState extends State<AlertDetailsPage> {
  final String _currentLanguage = 'EN'; // EN or HI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Alert Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          // Language Selector - FIXED with highlighted state
          _buildLanguageSelector(),

          const SizedBox(width: 8),

          // Voice button
          ValueListenableBuilder<bool>(
            valueListenable: TtsService.instance.isSpeaking,
            builder: (_, speaking, __) {
              return IconButton(
                icon: Icon(speaking ? Icons.stop_circle : Icons.volume_up),
                tooltip: speaking ? 'Stop' : 'Listen',
                onPressed: speaking
                    ? () => TtsService.instance.stop()
                    : _speakAlertSummary,
              );
            },
          ),

          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Severity Header Card
            _buildHeaderCard(),

            const SizedBox(height: 20),

            // Description Card
            _buildDescriptionCard(),

            const SizedBox(height: 16),

            // What to DO Card
            _buildDoSection(),

            const SizedBox(height: 16),

            // What NOT to DO Card
            _buildDontSection(),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==================== LANGUAGE SELECTOR (FIXED HIGHLIGHTING) ====================
  Widget _buildLanguageSelector() {
    return ValueListenableBuilder<bool>(
      valueListenable: TtsService.instance.isSpeaking,
      builder: (_, __, ___) {
        final isHindi =
            TtsService.instance.currentLanguage == TtsLanguages.hiIN;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _showLanguageSheet();
          },
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isHindi
                  ? const Color(0xFF2E7D32).withValues(alpha: (0.15))
                  : const Color(0xFF2E7D32).withValues(alpha: (0.1)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHindi
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF2E7D32).withValues(alpha: (0.3)),
                width: isHindi ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 16, color: Color(0xFF2E7D32)),
                const SizedBox(width: 4),
                Text(
                  isHindi ? "HI" : "EN",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
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

  // ==================== HEADER CARD ====================
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _getSeverityGradient(widget.alert.severity),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: _getSeverityColor(widget.alert.severity)
                .withValues(alpha: (0.3)),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon with background circle
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: (0.25)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: (0.1)),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.alert.typeIcon,
                style: const TextStyle(fontSize: 52),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            widget.alert.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          // Severity Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: (0.3)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: (0.5)), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getSeverityIcon(widget.alert.severity),
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.alert.severityText.toUpperCase()} ALERT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DESCRIPTION CARD ====================
  Widget _buildDescriptionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: (0.08))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: (0.04)),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: (0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              widget.alert.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DO SECTION ====================
  Widget _buildDoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF4CAF50).withValues(alpha: (0.3)),
              width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: (0.08)),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: (0.15)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'What to Do',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4CAF50),
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.alert.doList.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildListItem(
                context,
                item,
                true,
                index + 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  // ==================== DON'T SECTION ====================
  Widget _buildDontSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFF44336).withValues(alpha: (0.3)),
              width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF44336).withValues(alpha: (0.08)),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withValues(alpha: (0.15)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cancel,
                    color: Color(0xFFF44336),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'What NOT to Do',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF44336),
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.alert.dontList.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildListItem(
                context,
                item,
                false,
                index + 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  // ==================== LIST ITEM (NUMBERED) ====================
  Widget _buildListItem(
      BuildContext context, String text, bool isDo, int number) {
    final color = isDo ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: (0.15)),
              shape: BoxShape.circle,
              border:
                  Border.all(color: color.withValues(alpha: (0.4)), width: 1.5),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      height: 1.4,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Primary action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'Acknowledge & Close',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                TtsService.instance.stop();
                Navigator.pop(context);
              },
            ),
          ),

          const SizedBox(height: 12),

          // Secondary action
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.home, color: Color(0xFF2E7D32)),
              label: const Text(
                'Back to Home',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                TtsService.instance.stop();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== LANGUAGE SHEET ====================
  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // English
            _buildLanguageTile(
              'English',
              'Default voice',
              'EN',
              _currentLanguage == 'EN',
            ),

            const SizedBox(height: 12),

            // Hindi
            _buildLanguageTile(
              'हिन्दी',
              'Hindi voice (if installed on device)',
              'HI',
              _currentLanguage == 'HI',
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
      String title, String subtitle, String code, bool selected) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.selectionClick();
        TtsService.instance.setLanguage(
          code == 'HI' ? TtsLanguages.hiIN : 'en-US',
        );
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2E7D32).withValues(alpha: (0.1))
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          selected ? const Color(0xFF2E7D32) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? const Color(0xFF2E7D32) : Colors.grey.shade400,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== VOICE HELPERS ====================
  Future<void> _speakAlertSummary() async {
    HapticFeedback.mediumImpact();
    final tts = TtsService.instance;
    final lang = tts.currentLanguage;

    // Build DO's and DON'Ts text
    final doText = widget.alert.doList.join(". ");
    final dontText = widget.alert.dontList.join(". ");

    // English summary
    final summaryEN = "${widget.alert.title}. "
        "${widget.alert.severityText} severity alert. "
        "${widget.alert.description}. "
        "What to do: $doText. "
        "What NOT to do: $dontText.";

    // Hindi summary
    final severityHI = _getSeverityInHindi(widget.alert.severity);
    final summaryHI = "${widget.alert.title}. "
        "$severityHI गंभीरता की चेतावनी. "
        "${widget.alert.description}. "
        "क्या करें: $doText. "
        "क्या न करें: $dontText.";

    await tts.speak(
      lang == TtsLanguages.hiIN ? summaryHI : summaryEN,
      languageCode: lang,
    );
  }

  String _getSeverityInHindi(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return "कम";
      case AlertSeverity.medium:
        return "मध्यम";
      case AlertSeverity.high:
        return "उच्च";
      case AlertSeverity.critical:
        return "गंभीर";
    }
  }

  // ==================== SEVERITY HELPERS ====================
  LinearGradient _getSeverityGradient(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AlertSeverity.medium:
        return const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFEF6C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AlertSeverity.high:
      case AlertSeverity.critical:
        return const LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return const Color(0xFF42A5F5);
      case AlertSeverity.medium:
        return const Color(0xFFFFA726);
      case AlertSeverity.high:
      case AlertSeverity.critical:
        return const Color(0xFFEF5350);
    }
  }

  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Icons.info;
      case AlertSeverity.medium:
        return Icons.warning_amber;
      case AlertSeverity.high:
      case AlertSeverity.critical:
        return Icons.error;
    }
  }
}
