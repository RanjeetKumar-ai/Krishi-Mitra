/// Crop Detail Screen — Animated Phase Headers + TTS Integration
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

class CropDetailPage extends StatefulWidget {
  final CropModel crop;
  const CropDetailPage({super.key, required this.crop});

  @override
  State<CropDetailPage> createState() => _CropDetailPageState();
}

class _CropDetailPageState extends State<CropDetailPage>
    with TickerProviderStateMixin {
  late final AnimationController _phaseAnim;
  late final AnimationController _pulseAnim;
  late final AnimationController _floatAnim;

  @override
  void initState() {
    super.initState();
    _phaseAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _pulseAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _floatAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _phaseAnim.dispose();
    _pulseAnim.dispose();
    _floatAnim.dispose();
    super.dispose();
  }

  // ── TTS ─────────────────────────────────────────────────────────
  Future<void> _speakCropSummary() async {
    HapticFeedback.mediumImpact();
    final tts = TtsService.instance;
    final lang = tts.currentLanguage;
    final summaryEN = "${widget.crop.name} details. "
        "Current phase: ${widget.crop.phaseText}. "
        "Growth progress: ${widget.crop.progressPercentage} percent. "
        "Field size: ${widget.crop.fieldSize} acres. "
        "Soil type: ${widget.crop.soilType}. "
        "Health status: ${widget.crop.healthStatusText}. "
        "${widget.crop.nextPhase != null ? 'Next phase ${_getPhaseText(widget.crop.nextPhase!)} expected in ${widget.crop.daysToNextPhase} days.' : 'Ready for harvest.'}";
    final summaryHI = "${widget.crop.name} विवरण. "
        "वर्तमान चरण: ${widget.crop.phaseText}. "
        "विकास प्रगति: ${widget.crop.progressPercentage} प्रतिशत. "
        "खेत का आकार: ${widget.crop.fieldSize} एकड़. "
        "मिट्टी का प्रकार: ${widget.crop.soilType}. "
        "स्वास्थ्य स्थिति: ${widget.crop.healthStatusText}. "
        "${widget.crop.nextPhase != null ? 'अगला चरण ${_getPhaseText(widget.crop.nextPhase!)} ${widget.crop.daysToNextPhase} दिनों में अपेक्षित.' : 'कटाई के लिए तैयार.'}";
    await tts.speak(lang == TtsLanguages.hiIN ? summaryHI : summaryEN,
        languageCode: lang);
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
        backgroundColor:
            _getHealthGradient(widget.crop.healthStatus).colors.first,
        foregroundColor: Colors.white,
        title: Text(widget.crop.name,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [
          const SizedBox(width: 8),
          ValueListenableBuilder<bool>(
            valueListenable: TtsService.instance.isSpeaking,
            builder: (_, speaking, __) => IconButton(
              icon: Icon(speaking ? Icons.stop_circle : Icons.volume_up,
                  color: Colors.white),
              tooltip: speaking ? 'Stop' : 'Listen',
              onPressed: speaking
                  ? () => TtsService.instance.stop()
                  : _speakCropSummary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
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
            _buildHeaderCard(context),
            const SizedBox(height: 20),
            _buildQuickStats(context),
            const SizedBox(height: 20),
            _buildGrowthProgress(context),
            const SizedBox(height: 20),
            _buildGrowthTimeline(context),
            const SizedBox(height: 20),
            if (widget.crop.nextPhase != null) _buildNextPhaseCard(context),
            if (widget.crop.nextPhase != null) const SizedBox(height: 20),
            _buildRecentActions(context),
            const SizedBox(height: 20),
            _buildUpcomingTasks(context),
            const SizedBox(height: 24),
            _buildActionButtons(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  // ════════════════════════════════════════════════════════════
  //  ANIMATED HEADER CARD — fixed two-zone layout
  // ════════════════════════════════════════════════════════════

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      // Animation zone (130) + Info bar (70) = 200 total
      height: 200,
      decoration: BoxDecoration(
        gradient: _getHealthGradient(widget.crop.healthStatus),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: _getHealthColor(widget.crop.healthStatus)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Column(
          children: [
            // ── TOP: Pure animation scene, no text ─────────────
            SizedBox(
              height: 130,
              child: _buildPhaseAnimation(),
            ),

            // ── BOTTOM: Solid opaque info bar ───────────────────
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: Colors.black.withValues(alpha: 0.30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Floating crop avatar
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, -2 + _floatAnim.value * 4),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                              width: 1.5),
                        ),
                        child: Center(
                          child: Text(widget.crop.iconEmoji,
                              style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Name + badges + progress bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.crop.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(children: [
                          _infoPill(
                              widget.crop.phaseText.toUpperCase(), Icons.eco),
                          const SizedBox(width: 5),
                          _infoPill(
                              widget.crop.healthStatusText, Icons.favorite,
                              color: Colors.white),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: widget.crop.progressPercentage / 100,
                                minHeight: 4,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.25),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.crop.progressPercentage}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill(String label, IconData icon, {Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.38), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 10),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2)),
      ]),
    );
  }

  Widget _buildPhaseAnimation() {
    switch (widget.crop.currentPhase) {
      case CropPhase.seedling:
        return _SeedlingAnimation(pulse: _pulseAnim, grow: _phaseAnim);
      case CropPhase.vegetative:
        return _VegetativeAnimation(ctrl: _phaseAnim, pulse: _pulseAnim);
      case CropPhase.flowering:
        return _FloweringAnimation(ctrl: _phaseAnim, pulse: _pulseAnim);
      case CropPhase.fruiting:
        return _FruitingAnimation(ctrl: _phaseAnim);
      case CropPhase.maturation:
        return _MaturationAnimation(ctrl: _phaseAnim, pulse: _pulseAnim);
      case CropPhase.harvest:
        return _HarvestAnimation(ctrl: _phaseAnim);
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  QUICK STATS
  // ════════════════════════════════════════════════════════════════

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
              value:
                  '${widget.crop.sowDate.day} Jan ${widget.crop.sowDate.year}',
              color: const Color(0xFF42A5F5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.landscape,
              label: 'Field Size',
              value: '${widget.crop.fieldSize} acres',
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
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  GROWTH PROGRESS
  // ════════════════════════════════════════════════════════════════

  Widget _buildGrowthProgress(BuildContext context) {
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
                    color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.trending_up,
                    color: Color(0xFF66BB6A), size: 22),
              ),
              const SizedBox(width: 12),
              Text('Growth Progress',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              Text(
                '${widget.crop.progressPercentage}%',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF66BB6A)),
              ),
            ]),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: widget.crop.progressPercentage / 100,
                minHeight: 14,
                backgroundColor: Colors.grey[200],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF66BB6A)),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              _buildHealthBadge('Soil: ${widget.crop.soilType}', Colors.brown),
              const SizedBox(width: 8),
              _buildHealthBadge('Health: ${widget.crop.healthStatusText}',
                  _getHealthColor(widget.crop.healthStatus)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  GROWTH TIMELINE
  // ════════════════════════════════════════════════════════════════

  Widget _buildGrowthTimeline(BuildContext context) {
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
                    color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.timeline,
                    color: Color(0xFF42A5F5), size: 22),
              ),
              const SizedBox(width: 12),
              Text('Growth Timeline',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            ]),
            const SizedBox(height: 18),
            _buildTimelineWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineWidget() {
    final phases = CropPhase.values;
    final currentPhaseIndex = phases.indexOf(widget.crop.currentPhase);

    return Column(
      children: List.generate(phases.length, (index) {
        final phase = phases[index];
        final isCompleted = index < currentPhaseIndex;
        final isCurrent = index == currentPhaseIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
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
                                  .withValues(alpha: 0.4),
                              blurRadius: 8)
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
                        : Colors.grey[300]),
            ]),
            const SizedBox(width: 14),
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
                              : Colors.black87),
                    ),
                    if (isCurrent)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF66BB6A).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Current',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF66BB6A))),
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

  // ════════════════════════════════════════════════════════════════
  //  NEXT PHASE CARD
  // ════════════════════════════════════════════════════════════════

  Widget _buildNextPhaseCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle),
            child: const Icon(Icons.next_plan, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Next Phase',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  _getPhaseText(widget.crop.nextPhase!),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expected in ${widget.crop.daysToNextPhase} days',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  RECENT ACTIONS
  // ════════════════════════════════════════════════════════════════

  Widget _buildRecentActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF66BB6A).withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF66BB6A).withValues(alpha: 0.08),
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
                    color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.history,
                    color: Color(0xFF66BB6A), size: 22),
              ),
              const SizedBox(width: 12),
              Text('Recent Actions',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            ]),
            const SizedBox(height: 16),
            ...widget.crop.recentActions
                .map((action) => _buildActionItem(action, true)),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  UPCOMING TASKS
  // ════════════════════════════════════════════════════════════════

  Widget _buildUpcomingTasks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFFFA726).withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFFFA726).withValues(alpha: 0.08),
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
                    color: const Color(0xFFFFA726).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.assignment,
                    color: Color(0xFFFFA726), size: 22),
              ),
              const SizedBox(width: 12),
              Text('Upcoming Tasks',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            ]),
            const SizedBox(height: 16),
            ...widget.crop.upcomingTasks
                .map((task) => _buildActionItem(task, false)),
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
            child:
                Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  ACTION BUTTONS
  // ════════════════════════════════════════════════════════════════

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF5350),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.medical_services),
              label: const Text('Disease History',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              onPressed: () {
                HapticFeedback.mediumImpact();
                TtsService.instance.stop();
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
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.lightbulb),
              label: const Text('Tips',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              onPressed: () {
                HapticFeedback.mediumImpact();
                TtsService.instance.stop();
              },
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.note_add, color: Color(0xFF2E7D32)),
              label: const Text('Add Note',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32))),
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
                side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.camera_alt, color: Color(0xFF2E7D32)),
              label: const Text('Photo',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32))),
              onPressed: () {
                HapticFeedback.lightImpact();
              },
            ),
          ),
        ]),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  ADD NOTE DIALOG
  // ════════════════════════════════════════════════════════════════

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

  // ════════════════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════════════════

  LinearGradient _getHealthGradient(CropHealthStatus status) {
    switch (status) {
      case CropHealthStatus.good:
        return const LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
      case CropHealthStatus.warning:
        return const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFEF6C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
      case CropHealthStatus.risk:
        return const LinearGradient(
            colors: [Color(0xFFEF5350), Color(0xFFC62828)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
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

// ════════════════════════════════════════════════════════════════════
//  🌱 SEEDLING
// ════════════════════════════════════════════════════════════════════
class _SeedlingAnimation extends StatelessWidget {
  final AnimationController pulse;
  final AnimationController grow;
  const _SeedlingAnimation({required this.pulse, required this.grow});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pulse, grow]),
      builder: (_, __) {
        return Stack(clipBehavior: Clip.hardEdge, children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF81C784), Color(0xFF388E3C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Soil strip
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
                height: 28,
                color: const Color(0xFF5D4037).withValues(alpha: 0.8)),
          ),
          // Water droplets (upper 80px only)
          ...List.generate(10, (i) {
            final phase = (grow.value * 0.85 + i * 0.10) % 1.0;
            return Positioned(
              left: (i * 36.0) % 350,
              top: phase * 90 - 12,
              child: Opacity(
                opacity: (1.0 - phase * 0.85).clamp(0.0, 1.0),
                child: const Text('💧', style: TextStyle(fontSize: 12)),
              ),
            );
          }),
          // Sprout centred, above soil
          Positioned(
            bottom: 22,
            left: 0,
            right: 0,
            child: Center(
              child:
                  Text('🌱', style: TextStyle(fontSize: 28 + pulse.value * 8)),
            ),
          ),
          Positioned(top: 8, left: 10, child: _stageBadge('🌧 Germinating')),
        ]);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  🌿 VEGETATIVE — sun constrained to upper-right quadrant
// ════════════════════════════════════════════════════════════════════
class _VegetativeAnimation extends StatelessWidget {
  final AnimationController ctrl;
  final AnimationController pulse;
  const _VegetativeAnimation({required this.ctrl, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ctrl, pulse]),
      builder: (_, __) {
        return Stack(clipBehavior: Clip.hardEdge, children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Soil base
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
                height: 5,
                color: const Color(0xFF4E342E).withValues(alpha: 0.5)),
          ),
          // Sun — kept in upper-right, small enough not to interfere
          Positioned(
            top: 8,
            right: 24,
            child: Transform.rotate(
              angle: ctrl.value * 2 * pi,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(8, (i) {
                    final angle = i * pi / 4;
                    return Transform.translate(
                      offset: Offset(cos(angle) * 20, sin(angle) * 20),
                      child: Container(
                        width: 2,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Colors.yellow.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                  const Text('🌤️', style: TextStyle(fontSize: 22)),
                ],
              ),
            ),
          ),
          // Plants row at bottom — sized to stay inside 130px
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                final size = 18.0 + pulse.value * 8;
                return Text(i == 2 ? '🌿' : '🌱',
                    style: TextStyle(fontSize: size));
              }),
            ),
          ),
          Positioned(top: 8, left: 10, child: _stageBadge('☀ Growing Fast')),
        ]);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  🌸 FLOWERING
// ════════════════════════════════════════════════════════════════════
class _FloweringAnimation extends StatelessWidget {
  final AnimationController ctrl;
  final AnimationController pulse;
  const _FloweringAnimation({required this.ctrl, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ctrl, pulse]),
      builder: (_, __) {
        return Stack(clipBehavior: Clip.hardEdge, children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFCE93D8), Color(0xFF6A1B9A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Rings centred in top zone
          ...List.generate(3, (i) {
            final ringPhase = (ctrl.value + i * 0.33) % 1.0;
            return Center(
              child: Container(
                width: 30 + ringPhase * 130,
                height: 30 + ringPhase * 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.pinkAccent
                        .withValues(alpha: (1.0 - ringPhase) * 0.4),
                    width: 1.5,
                  ),
                ),
              ),
            );
          }),
          // Orbiting petals — radius kept tight so they stay in zone
          ...List.generate(6, (i) {
            final angle = ctrl.value * 2 * pi + i * pi / 3;
            const radius = 40.0;
            return Positioned(
              left: 170 + cos(angle) * radius,
              top: 55 + sin(angle) * radius,
              child: Text(i % 2 == 0 ? '🌸' : '🌺',
                  style: const TextStyle(fontSize: 14)),
            );
          }),
          const Center(
            child: Text('🌻', style: TextStyle(fontSize: 38)),
          ),
          Positioned(top: 8, left: 10, child: _stageBadge('🌸 Flowering')),
        ]);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  🍅 FRUITING
// ════════════════════════════════════════════════════════════════════
class _FruitingAnimation extends StatelessWidget {
  final AnimationController ctrl;
  const _FruitingAnimation({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        return Stack(clipBehavior: Clip.hardEdge, children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEF9A9A), Color(0xFFB71C1C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Leaf backdrop
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                  4, (_) => const Text('🌿', style: TextStyle(fontSize: 18))),
            ),
          ),
          // Bobbing fruits — capped so they don't go below 130px
          ...List.generate(7, (i) {
            final bob = sin((ctrl.value * 2 * pi) + i * 0.9) * 6;
            const fruits = ['🍅', '🌽', '🥭', '🍆', '🥕', '🍅', '🌽'];
            return Positioned(
              bottom: 18.0 + bob,
              left: 8.0 + i * 50,
              child: Text(fruits[i], style: const TextStyle(fontSize: 22)),
            );
          }),
          Positioned(top: 8, left: 10, child: _stageBadge('🍅 Fruiting')),
        ]);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  🌾 MATURATION
// ════════════════════════════════════════════════════════════════════
class _MaturationAnimation extends StatelessWidget {
  final AnimationController ctrl;
  final AnimationController pulse;
  const _MaturationAnimation({required this.ctrl, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ctrl, pulse]),
      builder: (_, __) {
        return Stack(clipBehavior: Clip.hardEdge, children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFE082), Color(0xFFF57F17)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Radial glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.yellow.withValues(alpha: 0.06 + pulse.value * 0.10),
                    Colors.transparent,
                  ],
                  radius: 0.7,
                ),
              ),
            ),
          ),
          // Swaying wheat — bottom 50px
          Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(8, (i) {
                final sway = sin(ctrl.value * 2 * pi + i * 0.78) * 0.12;
                return Transform(
                  transform: Matrix4.identity()
                    ..translateByDouble(12.0, 24.0, 0, 0)
                    ..rotateZ(sway)
                    ..translateByDouble(-12.0, -24.0, 0, 0),
                  child: Text(i % 2 == 0 ? '🌾' : '🌿',
                      style: const TextStyle(fontSize: 26)),
                );
              }),
            ),
          ),
          Positioned(top: 8, left: 10, child: _stageBadge('🌾 Maturing')),
        ]);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  🚜 HARVEST
// ════════════════════════════════════════════════════════════════════
class _HarvestAnimation extends StatelessWidget {
  final AnimationController ctrl;
  const _HarvestAnimation({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        return Stack(clipBehavior: Clip.hardEdge, children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFE65100)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Falling particles — contained within 130px height
          ...List.generate(16, (i) {
            final phase = (ctrl.value * 0.65 + i * 0.063) % 1.0;
            const particles = ['🌾', '🌽', '⭐', '✨', '🌾', '✨'];
            return Positioned(
              left: (i * 22.0) % 360,
              top: phase * 130 - 18,
              child: Opacity(
                opacity: (1.0 - phase).clamp(0.0, 1.0),
                child: Text(
                  particles[i % particles.length],
                  style: TextStyle(fontSize: 10.0 + (i % 3) * 4),
                ),
              ),
            );
          }),
          // Tractor at bottom
          Positioned(
            bottom: 6,
            left: (ctrl.value * 320) - 40,
            child: const Text('🚜', style: TextStyle(fontSize: 30)),
          ),
          Positioned(top: 8, left: 10, child: _stageBadge('🚜 Harvest!')),
        ]);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  SHARED HELPER — stage badge widget
// ════════════════════════════════════════════════════════════════════
Widget _stageBadge(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.32),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(label,
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 0.2)),
  );
}
