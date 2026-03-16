/// Phase Preparation Screen — Animated Header + TTS Integration
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/crop_model.dart';
import '../../../services/localization/tts_service.dart';
import '../../../services/localization/tts_languages.dart';

// ════════════════════════════════════════════════════════════════════
//  MAIN PAGE
// ════════════════════════════════════════════════════════════════════

class PhasePreparationPage extends StatefulWidget {
  final CropModel crop;
  const PhasePreparationPage({super.key, required this.crop});

  @override
  State<PhasePreparationPage> createState() => _PhasePreparationPageState();
}

class _PhasePreparationPageState extends State<PhasePreparationPage>
    with TickerProviderStateMixin {
  bool _isSpeaking = false;
  final Set<int> _checkedTasks = {};

  late final AnimationController _headerAnim;
  late final AnimationController _arrowAnim;
  late final AnimationController _pulseAnim;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
    _arrowAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 850))
      ..repeat(reverse: true);
    _pulseAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _arrowAnim.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
        title: const Text(
          'Phase Preparation',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSpeaking ? Icons.stop_circle : Icons.volume_up,
              color: Colors.white,
            ),
            tooltip: _isSpeaking ? 'Stop' : 'Listen',
            onPressed: () {
              HapticFeedback.mediumImpact();
              _toggleVoice(); // ← already correct if you have this
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildNextPhaseCard(),
            const SizedBox(height: 20),
            _buildPreparationChecklist(),
            const SizedBox(height: 20),
            _buildFertilizerGuidance(),
            const SizedBox(height: 16),
            _buildWaterManagement(),
            const SizedBox(height: 16),
            _buildPestPrevention(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  ANIMATED HEADER
  // ════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    final currentLabel = _getPhaseText(widget.crop.currentPhase);
    final nextLabel = _getPhaseText(widget.crop.nextPhase!);
    final days = widget.crop.daysToNextPhase ?? 0;
    final isUrgent = days <= 7;

    return Container(
      width: double.infinity,
      // Top animation zone (118) + bottom info bar (64) = 182
      height: 182,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Column(
          children: [
            // ── TOP: Animation scene (118px, no text) ───────────
            SizedBox(
              height: 118,
              child: AnimatedBuilder(
                animation: Listenable.merge([_headerAnim, _pulseAnim]),
                builder: (_, __) {
                  return Stack(clipBehavior: Clip.hardEdge, children: [
                    // Wave lines
                    ...List.generate(3, (i) {
                      return Positioned(
                        top: 4.0 + i * 8,
                        left: 0,
                        right: 0,
                        child: Opacity(
                          opacity: 0.07 + i * 0.03,
                          child: CustomPaint(
                            size: const Size(double.infinity, 10),
                            painter: _WavePainter(
                              phase: _headerAnim.value * 2 * pi + i * 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }),
                    // Rising sparkle particles
                    ...List.generate(12, (i) {
                      final phase =
                          (_headerAnim.value * 0.55 + i * 0.083) % 1.0;
                      return Positioned(
                        bottom: phase * 118,
                        left: (i * 30.0) % 360,
                        child: Opacity(
                          opacity: (sin(phase * pi) * 0.35).clamp(0.0, 1.0),
                          child: Container(
                            width: 3.0 + (i % 3),
                            height: 3.0 + (i % 3),
                            decoration: BoxDecoration(
                              color: Colors.lightGreenAccent
                                  .withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                    // Centred crop avatar with pulse ring
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 72 + _pulseAnim.value * 8,
                            height: 72 + _pulseAnim.value * 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(
                                    alpha: 0.22 - _pulseAnim.value * 0.15),
                                width: 2,
                              ),
                            ),
                          ),
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.18),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1.5),
                            ),
                            child: Center(
                              child: Text(widget.crop.iconEmoji,
                                  style: const TextStyle(fontSize: 28)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]);
                },
              ),
            ),

            // ── BOTTOM: Solid info bar (64px) ────────────────────
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              color: Colors.black.withValues(alpha: 0.28),
              child: AnimatedBuilder(
                animation: _arrowAnim,
                builder: (_, __) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Current phase pill
                      _transitionPill(
                        emoji: widget.crop.iconEmoji,
                        label: currentLabel,
                        color: Colors.white.withValues(alpha: 0.22),
                        borderColor: Colors.white.withValues(alpha: 0.45),
                      ),
                      const SizedBox(width: 6),
                      // Bouncing arrow
                      Transform.translate(
                        offset: Offset(3 * _arrowAnim.value, 0),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white70, size: 18),
                      ),
                      const SizedBox(width: 6),
                      // Next phase pill
                      _transitionPill(
                        emoji: _getPhaseEmoji(widget.crop.nextPhase!),
                        label: nextLabel,
                        color: const Color(0xFF1565C0).withValues(alpha: 0.65),
                        borderColor: Colors.white.withValues(alpha: 0.55),
                        bold: true,
                      ),
                      const Spacer(),
                      // Days countdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: isUrgent
                              ? Colors.orange.withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: isUrgent
                              ? Border.all(
                                  color: Colors.orangeAccent, width: 1.2)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUrgent
                                  ? Icons.warning_amber_rounded
                                  : Icons.hourglass_bottom,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$days d',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── VERY BOTTOM: Thin action callout strip ────────────
            Container(
              height: 0, // collapsed — message moved into info bar
            ),
          ],
        ),
      ),
    );
  }

  Widget _transitionPill({
    required String emoji,
    required String label,
    required Color color,
    required Color borderColor,
    Color textColor = Colors.white,
    bool bold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  NEXT PHASE CARD
  // ════════════════════════════════════════════════════════════════

  Widget _buildNextPhaseCard() {
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
              color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.schedule, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Next Phase',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPhaseText(widget.crop.nextPhase!),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Expected in ${widget.crop.daysToNextPhase} days',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  PREPARATION CHECKLIST
  // ════════════════════════════════════════════════════════════════

  Widget _buildPreparationChecklist() {
    final tasks = _getPreparationTasks(widget.crop.nextPhase!);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.checklist,
                    color: Color(0xFF2E7D32), size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'What to Prepare',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              Text(
                '${_checkedTasks.length}/${tasks.length}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32)),
              ),
            ]),
            const SizedBox(height: 16),
            ...List.generate(
                tasks.length, (i) => _buildChecklistItem(tasks[i], i)),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String task, int index) {
    final isChecked = _checkedTasks.contains(index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            if (isChecked) {
              _checkedTasks.remove(index);
            } else {
              _checkedTasks.add(index);
            }
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF2E7D32) : Colors.transparent,
                border: Border.all(color: const Color(0xFF2E7D32), width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  task,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    decoration: isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isChecked ? Colors.grey[500] : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  FERTILIZER GUIDANCE
  // ════════════════════════════════════════════════════════════════

  Widget _buildFertilizerGuidance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF66BB6A).withValues(alpha: 0.4), width: 2),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF66BB6A).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.spa, color: Color(0xFF66BB6A), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Fertilizer & Nutrients',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF66BB6A).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NPK Requirements',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getFertilizerGuidance(widget.crop.nextPhase!),
                    style: const TextStyle(
                        fontSize: 14, height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  WATER MANAGEMENT
  // ════════════════════════════════════════════════════════════════

  Widget _buildWaterManagement() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF42A5F5).withValues(alpha: 0.4), width: 2),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF42A5F5).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.water_drop,
                    color: Color(0xFF42A5F5), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Water Management',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF42A5F5).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Irrigation Schedule',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getWaterGuidance(widget.crop.nextPhase!),
                    style: const TextStyle(
                        fontSize: 14, height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  PEST PREVENTION
  // ════════════════════════════════════════════════════════════════

  Widget _buildPestPrevention() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFFFA726).withValues(alpha: 0.4), width: 2),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFFFA726).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield,
                    color: Color(0xFFFFA726), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Pest Prevention',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA726).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preventive Measures',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getPestGuidance(widget.crop.nextPhase!),
                    style: const TextStyle(
                        fontSize: 14, height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  ACTION BUTTONS
  // ════════════════════════════════════════════════════════════════

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            icon: const Icon(Icons.bookmark),
            label: const Text(
              'Save Preparation Plan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _savePlan();
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.notifications, color: Color(0xFF2E7D32)),
            label: const Text(
              'Set Reminder',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32)),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _setReminder();
            },
          ),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  ACTION HANDLERS
  // ════════════════════════════════════════════════════════════════

  void _savePlan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparation plan saved successfully'),
        backgroundColor: Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setReminder() {
    final daysUntilReminder = (widget.crop.daysToNextPhase ?? 0) - 5;
    final reminderDays = daysUntilReminder > 0 ? daysUntilReminder : 1;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for $reminderDays days from now'),
        backgroundColor: const Color(0xFF42A5F5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleVoice() {
    // If already speaking → STOP and reset flag
    if (_isSpeaking) {
      TtsService.instance.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    // Start speaking
    setState(() => _isSpeaking = true);
    final tts = TtsService.instance;
    final lang = tts.currentLanguage;
    final tasks = _getPreparationTasks(widget.crop.nextPhase!).join('. ');

    final summaryEN =
        '${widget.crop.name}. Preparing for ${_getPhaseText(widget.crop.nextPhase!)}. '
        'Expected in ${widget.crop.daysToNextPhase} days. '
        'Tasks to complete: $tasks';
    final summaryHI =
        '${widget.crop.name}. ${_getPhaseText(widget.crop.nextPhase!)} के लिए तैयारी. '
        '${widget.crop.daysToNextPhase} दिनों में अपेक्षित. '
        'कार्य: $tasks';

    tts
        .speak(
      lang == TtsLanguages.hiIN ? summaryHI : summaryEN,
      languageCode: lang,
    )
        .then((_) {
      // Auto-reset when speech naturally finishes
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  // ════════════════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════════════════

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

  String _getPhaseEmoji(CropPhase phase) {
    switch (phase) {
      case CropPhase.seedling:
        return '🌱';
      case CropPhase.vegetative:
        return '🌿';
      case CropPhase.flowering:
        return '🌸';
      case CropPhase.fruiting:
        return '🍅';
      case CropPhase.maturation:
        return '🌾';
      case CropPhase.harvest:
        return '🚜';
    }
  }

  List<String> _getPreparationTasks(CropPhase phase) {
    switch (phase) {
      case CropPhase.seedling:
        return [
          'Prepare seed bed and soil',
          'Source quality seeds',
          'Set up nursery trays',
          'Check moisture levels',
          'Arrange germination covers',
        ];
      case CropPhase.vegetative:
        return [
          'Apply nitrogen-rich fertilizers',
          'Set up drip irrigation',
          'Prepare weed control plan',
          'Check soil pH levels',
          'Stock growth boosters',
        ];
      case CropPhase.flowering:
        return [
          'Arrange phosphorus-rich fertilizers',
          'Check irrigation system',
          'Set up pest traps',
          'Prepare for increased watering',
          'Stock organic fungicides',
        ];
      case CropPhase.fruiting:
        return [
          'Increase potassium dosage',
          'Install fruit support structures',
          'Monitor for fruit borers',
          'Reduce nitrogen application',
          'Prepare harvest containers',
        ];
      case CropPhase.maturation:
        return [
          'Stop irrigation 10 days before harvest',
          'Arrange harvesting equipment',
          'Book transport and storage',
          'Check market prices',
          'Prepare drying area',
        ];
      case CropPhase.harvest:
        return [
          'Confirm harvest team availability',
          'Inspect cutting tools',
          'Arrange cold storage if needed',
          'Contact buyers',
          'Prepare weighing equipment',
        ];
    }
  }

  String _getFertilizerGuidance(CropPhase phase) {
    switch (phase) {
      case CropPhase.seedling:
        return 'Apply starter fertilizer NPK 12:32:16 @ 1kg per acre. '
            'Focus on phosphorus for strong root development.';
      case CropPhase.vegetative:
        return 'Apply Urea @ 25kg per acre for leafy growth. '
            'Supplement with micronutrients (Zinc, Iron) every 15 days.';
      case CropPhase.flowering:
        return 'Apply NPK 10:52:10 @ 2kg per acre during early flowering. '
            'Supplement with micronutrients (Zinc, Boron) for better flower development.';
      case CropPhase.fruiting:
        return 'Apply MOP (Muriate of Potash) @ 20kg per acre. '
            'Calcium and Magnesium spray helps in fruit development.';
      case CropPhase.maturation:
        return 'Avoid nitrogen. Apply potassium sulfate @ 10kg per acre. '
            'Foliar spray of Boron improves grain quality.';
      case CropPhase.harvest:
        return 'No fertilizer required at this stage. '
            'Focus on field preparation for the next crop cycle.';
    }
  }

  String _getWaterGuidance(CropPhase phase) {
    switch (phase) {
      case CropPhase.seedling:
        return 'Light watering twice daily. Maintain soil moisture at 60%. '
            'Avoid waterlogging — use fine mist spray.';
      case CropPhase.vegetative:
        return 'Water every 4–5 days. Maintain soil moisture at 65–70%. '
            'Use furrow or drip irrigation for best results.';
      case CropPhase.flowering:
        return 'Increase irrigation frequency to once every 3 days. '
            'Maintain soil moisture at 70–80%. Use drip irrigation.';
      case CropPhase.fruiting:
        return 'Critical stage — water every 2–3 days consistently. '
            'Avoid water stress; maintain 75–80% soil moisture.';
      case CropPhase.maturation:
        return 'Reduce watering gradually. Stop 10–12 days before harvest '
            'to improve grain quality and ease harvesting.';
      case CropPhase.harvest:
        return 'No irrigation needed. Dry field conditions help '
            'machinery movement and reduce post-harvest losses.';
    }
  }

  String _getPestGuidance(CropPhase phase) {
    switch (phase) {
      case CropPhase.seedling:
        return 'Apply seed treatment fungicide before sowing. '
            'Watch for damping-off disease. Use neem cake in soil.';
      case CropPhase.vegetative:
        return 'Monitor for aphids and leaf miners weekly. '
            'Apply systemic insecticide if infestation exceeds threshold.';
      case CropPhase.flowering:
        return 'Apply neem oil spray weekly as preventive measure. '
            'Monitor for aphids and thrips. Install yellow sticky traps.';
      case CropPhase.fruiting:
        return 'Watch for fruit borers and mealybugs. '
            'Use pheromone traps. Avoid broad-spectrum pesticides near harvest.';
      case CropPhase.maturation:
        return 'Bird netting recommended. Check for rodent activity. '
            'Minimal chemical intervention at this stage.';
      case CropPhase.harvest:
        return 'Inspect harvested produce for post-harvest pests. '
            'Use hermetic bags for storage. Keep storage area clean and dry.';
    }
  }
}

// ════════════════════════════════════════════════════════════════════
//  WAVE PAINTER — subtle animated wave lines in header background
// ════════════════════════════════════════════════════════════════════

class _WavePainter extends CustomPainter {
  final double phase;
  final Color color;

  const _WavePainter({required this.phase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          sin((x / size.width * 2 * pi) + phase) * (size.height * 0.4);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.phase != phase || old.color != color;
}
