/// Crop Detail Screen - REDESIGNED with TTS Integration
/// Farmer-friendly, informative with highlighted language selector
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/crop_model.dart';

// ✅ TTS imports
import '../../../services/localization/tts_service.dart';
import '../../../services/localization/tts_languages.dart';

class CropDetailPage extends StatelessWidget {
  final CropModel crop;

  const CropDetailPage({super.key, required this.crop});

  // ✅ TTS: Speak crop summary in English/Hindi
  Future<void> _speakCropSummary() async {
    HapticFeedback.mediumImpact();
    final tts = TtsService.instance;
    final lang = tts.currentLanguage;

    // English summary
    final summaryEN = "${crop.name} details. "
        "Current phase: ${crop.phaseText}. "
        "Growth progress: ${crop.progressPercentage} percent. "
        "Field size: ${crop.fieldSize} acres. "
        "Soil type: ${crop.soilType}. "
        "Health status: ${crop.healthStatusText}. "
        "${crop.nextPhase != null ? 'Next phase ${_getPhaseText(crop.nextPhase!)} expected in ${crop.daysToNextPhase} days.' : 'Ready for harvest.'}";

    // Hindi summary
    final summaryHI = "${crop.name} विवरण. "
        "वर्तमान चरण: ${crop.phaseText}. "
        "विकास प्रगति: ${crop.progressPercentage} प्रतिशत. "
        "खेत का आकार: ${crop.fieldSize} एकड़. "
        "मिट्टी का प्रकार: ${crop.soilType}. "
        "स्वास्थ्य स्थिति: ${crop.healthStatusText}. "
        "${crop.nextPhase != null ? 'अगला चरण ${_getPhaseText(crop.nextPhase!)} ${crop.daysToNextPhase} दिनों में अपेक्षित.' : 'कटाई के लिए तैयार.'}";

    await tts.speak(
      lang == TtsLanguages.hiIN ? summaryHI : summaryEN,
      languageCode: lang,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          crop.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          // Language Selector - FIXED with highlighted state
          _buildLanguageSelector(context),

          const SizedBox(width: 8),

          // Voice button with TTS integration
          ValueListenableBuilder<bool>(
            valueListenable: TtsService.instance.isSpeaking,
            builder: (_, speaking, __) {
              return IconButton(
                icon: Icon(speaking ? Icons.stop_circle : Icons.volume_up),
                tooltip: speaking ? 'Stop' : 'Listen',
                onPressed: speaking
                    ? () => TtsService.instance.stop()
                    : _speakCropSummary,
              );
            },
          ),

          // Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Navigate to edit crop
            },
          ),

          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Crop Info
            _buildHeaderCard(context),

            const SizedBox(height: 20),

            // Quick Stats Grid
            _buildQuickStats(context),

            const SizedBox(height: 20),

            // Growth Progress Card
            _buildGrowthProgress(context),

            const SizedBox(height: 20),

            // Growth Timeline
            _buildGrowthTimeline(context),

            const SizedBox(height: 20),

            // Next Phase Card (if applicable)
            if (crop.nextPhase != null) _buildNextPhaseCard(context),

            if (crop.nextPhase != null) const SizedBox(height: 20),

            // Recent Actions
            _buildRecentActions(context),

            const SizedBox(height: 20),

            // Upcoming Tasks
            _buildUpcomingTasks(context),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ==================== LANGUAGE SELECTOR (FIXED HIGHLIGHTING) ====================
  Widget _buildLanguageSelector(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TtsService.instance.isSpeaking,
      builder: (_, __, ___) {
        final isHindi =
            TtsService.instance.currentLanguage == TtsLanguages.hiIN;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _showLanguageSheet(context);
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
                const Icon(
                  Icons.language,
                  size: 16,
                  color: Color(0xFF2E7D32),
                ),
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
  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _getHealthGradient(crop.healthStatus),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: _getHealthColor(crop.healthStatus).withValues(alpha: (0.3)),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Crop Icon with glow
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: (0.25)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: (0.1)),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                crop.iconEmoji,
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Crop Name
          Text(
            crop.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
          ),

          const SizedBox(height: 10),

          // Current Phase Badge
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
                const Icon(Icons.eco, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  crop.phaseText.toUpperCase(),
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

  // ==================== QUICK STATS GRID ====================
  Widget _buildQuickStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.calendar_today,
              label: 'Sown On',
              value: '${crop.sowDate.day} Jan ${crop.sowDate.year}',
              color: const Color(0xFF42A5F5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.landscape,
              label: 'Field Size',
              value: '${crop.fieldSize} acres',
              color: const Color(0xFF66BB6A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: (0.3)), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: (0.1)),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: (0.15)),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== GROWTH PROGRESS ====================
  Widget _buildGrowthProgress(BuildContext context) {
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
                    color: const Color(0xFF66BB6A).withValues(alpha: (0.15)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Color(0xFF66BB6A),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Growth Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                const Spacer(),
                Text(
                  '${crop.progressPercentage}%',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF66BB6A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: crop.progressPercentage / 100,
                minHeight: 14,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation(Color(0xFF66BB6A)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildHealthBadge(
                  'Soil: ${crop.soilType}',
                  Colors.brown,
                ),
                const SizedBox(width: 8),
                _buildHealthBadge(
                  'Health: ${crop.healthStatusText}',
                  _getHealthColor(crop.healthStatus),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: (0.12)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: (0.4)), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ==================== GROWTH TIMELINE ====================
  Widget _buildGrowthTimeline(BuildContext context) {
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
                    color: const Color(0xFF42A5F5).withValues(alpha: (0.15)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.timeline,
                    color: Color(0xFF42A5F5),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Growth Timeline',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildTimelineWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineWidget() {
    final phases = CropPhase.values;
    final currentPhaseIndex = phases.indexOf(crop.currentPhase);

    return Column(
      children: List.generate(phases.length, (index) {
        final phase = phases[index];
        final isCompleted = index < currentPhaseIndex;
        final isCurrent = index == currentPhaseIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? const Color(0xFF66BB6A)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFF66BB6A)
                          : Colors.grey.shade400,
                      width: isCurrent ? 3 : 1.5,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: const Color(0xFF66BB6A)
                                  .withValues(alpha: (0.4)),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : (isCurrent
                          ? const Icon(Icons.fiber_manual_record,
                              color: Colors.white, size: 12)
                          : null),
                ),
                if (index < phases.length - 1)
                  Container(
                    width: 2,
                    height: 45,
                    color: isCompleted
                        ? const Color(0xFF66BB6A)
                        : Colors.grey[300],
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // Phase info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPhaseText(phase),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.w600,
                        color: isCurrent
                            ? const Color(0xFF66BB6A)
                            : Colors.black87,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF66BB6A).withValues(alpha: (0.15)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF66BB6A),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ==================== NEXT PHASE CARD ====================
  Widget _buildNextPhaseCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF42A5F5).withValues(alpha: (0.3)),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: (0.25)),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.next_plan,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next Phase',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPhaseText(crop.nextPhase!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expected in ${crop.daysToNextPhase} days',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: (0.9)),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== RECENT ACTIONS ====================
  Widget _buildRecentActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF66BB6A).withValues(alpha: (0.3)),
              width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF66BB6A).withValues(alpha: (0.08)),
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
                    color: const Color(0xFF66BB6A).withValues(alpha: (0.15)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Color(0xFF66BB6A),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recent Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...crop.recentActions.map(
              (action) => _buildActionItem(action, true),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== UPCOMING TASKS ====================
  Widget _buildUpcomingTasks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFFFA726).withValues(alpha: (0.3)),
              width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA726).withValues(alpha: (0.08)),
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
                    color: const Color(0xFFFFA726).withValues(alpha: (0.15)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.assignment,
                    color: Color(0xFFFFA726),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Upcoming Tasks',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...crop.upcomingTasks.map(
              (task) => _buildActionItem(task, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(String text, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? const Color(0xFF66BB6A) : const Color(0xFFFFA726),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Primary actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.medical_services),
                  label: const Text(
                    'Disease History',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    TtsService.instance.stop();
                    // TODO: Navigate to disease history
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.lightbulb),
                  label: const Text(
                    'Tips',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    TtsService.instance.stop();
                    // TODO: Navigate to recommendations
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Secondary actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side:
                        const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.note_add, color: Color(0xFF2E7D32)),
                  label: const Text(
                    'Add Note',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showAddNoteDialog(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side:
                        const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
                  label: const Text(
                    'Photo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // TODO: Open camera/gallery
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== LANGUAGE SHEET ====================
  void _showLanguageSheet(BuildContext context) {
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
            _buildLanguageTile(
              context,
              'English',
              'Default voice',
              'en-US',
              TtsService.instance.currentLanguage == 'en-US',
            ),
            const SizedBox(height: 12),
            _buildLanguageTile(
              context,
              'हिन्दी',
              'Hindi voice',
              TtsLanguages.hiIN,
              TtsService.instance.currentLanguage == TtsLanguages.hiIN,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    String title,
    String subtitle,
    String languageCode,
    bool selected,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.selectionClick();
        TtsService.instance.setLanguage(languageCode);
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
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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

  // ==================== ADD NOTE DIALOG ====================
  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Note'),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your note here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note saved successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================
  LinearGradient _getHealthGradient(CropHealthStatus status) {
    switch (status) {
      case CropHealthStatus.good:
        return const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CropHealthStatus.warning:
        return const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFEF6C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CropHealthStatus.risk:
        return const LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getHealthColor(CropHealthStatus status) {
    switch (status) {
      case CropHealthStatus.good:
        return const Color(0xFF66BB6A);
      case CropHealthStatus.warning:
        return const Color(0xFFFFA726);
      case CropHealthStatus.risk:
        return const Color(0xFFEF5350);
    }
  }

  String _getPhaseText(CropPhase phase) {
    switch (phase) {
      case CropPhase.seedling:
        return 'Seedling';
      case CropPhase.vegetative:
        return 'Vegetative';
      case CropPhase.flowering:
        return 'Flowering';
      case CropPhase.fruiting:
        return 'Fruiting';
      case CropPhase.maturation:
        return 'Maturation';
      case CropPhase.harvest:
        return 'Harvest';
    }
  }
}
