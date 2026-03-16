/// Alert Details Screen — Fixed header layout
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/alert_model.dart';
import '../../../services/localization/tts_service.dart';
import '../../../services/localization/tts_languages.dart';

class AlertDetailsPage extends StatefulWidget {
  final AlertModel alert;
  const AlertDetailsPage({super.key, required this.alert});
  @override
  State<AlertDetailsPage> createState() => _AlertDetailsPageState();
}

class _AlertDetailsPageState extends State<AlertDetailsPage>
    with TickerProviderStateMixin {
  late final AnimationController _rainCtrl;
  late final AnimationController _pestCtrl;
  late final AnimationController _heatCtrl;
  late final AnimationController _cropShakeCtrl;

  @override
  void initState() {
    super.initState();
    _rainCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat();
    _pestCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();
    _heatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _cropShakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _rainCtrl.dispose();
    _pestCtrl.dispose();
    _heatCtrl.dispose();
    _cropShakeCtrl.dispose();
    super.dispose();
  }

  _AlertCategory get _category {
    final t = widget.alert.title.toLowerCase();
    final icon = widget.alert.typeIcon;
    if (t.contains('rain') ||
        t.contains('flood') ||
        icon == '🌧️' ||
        icon == '🌊' ||
        icon == '⛈️') {
      return _AlertCategory.rain;
    }
    if (t.contains('pest') ||
        t.contains('worm') ||
        t.contains('insect') ||
        t.contains('locust') ||
        icon == '🐛' ||
        icon == '🦗' ||
        icon == '🐜') {
      return _AlertCategory.pest;
    }
    if (t.contains('heat') ||
        t.contains('drought') ||
        t.contains('dry') ||
        icon == '🌡️' ||
        icon == '☀️' ||
        icon == '🔥') {
      return _AlertCategory.heat;
    }
    return _AlertCategory.generic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            _getSeverityGradient(widget.alert.severity).colors.first,
        foregroundColor: Colors.white,
        title: const Text('Alert Details',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: TtsService.instance.isSpeaking,
            builder: (_, speaking, __) => IconButton(
              icon: Icon(speaking ? Icons.stop_circle : Icons.volume_up,
                  color: Colors.white),
              onPressed: speaking
                  ? () => TtsService.instance.stop()
                  : _speakAlertSummary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimatedHeader(),
            const SizedBox(height: 20),
            _buildDescriptionCard(),
            const SizedBox(height: 16),
            _buildDoSection(),
            const SizedBox(height: 16),
            _buildDontSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  ANIMATED HEADER  — fixed height + clear zone separation
  // ════════════════════════════════════════════════════════════

  Widget _buildAnimatedHeader() {
    return Container(
      width: double.infinity,
      // Fixed height: top animation zone (120) + bottom info bar (72)
      height: 192,
      decoration: BoxDecoration(
        gradient: _getSeverityGradient(widget.alert.severity),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: _getSeverityColor(widget.alert.severity)
                .withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
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
            // ── TOP: Animation zone (fixed 120px, never overlaps text) ──
            SizedBox(
              height: 120,
              child: _buildCategoryAnimation(),
            ),

            // ── BOTTOM: Solid info bar (72px) ──────────────────────────
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.alert.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          _buildSeverityBadge(),
                          const SizedBox(width: 8),
                          _buildActiveDot(),
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

  Widget _buildCategoryAnimation() {
    switch (_category) {
      case _AlertCategory.rain:
        return _RainAnimation(controller: _rainCtrl, cropShake: _cropShakeCtrl);
      case _AlertCategory.pest:
        return _PestAnimation(controller: _pestCtrl);
      case _AlertCategory.heat:
        return _HeatAnimation(controller: _heatCtrl);
      case _AlertCategory.generic:
        return _GenericAlertAnimation(
            controller: _heatCtrl, icon: widget.alert.typeIcon);
    }
  }

  Widget _buildSeverityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_getSeverityIcon(widget.alert.severity),
            color: Colors.white, size: 11),
        const SizedBox(width: 4),
        Text(
          '${widget.alert.severityText.toUpperCase()} ALERT',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4),
        ),
      ]),
    );
  }

  Widget _buildActiveDot() {
    return AnimatedBuilder(
      animation: _heatCtrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color:
                  Colors.white.withValues(alpha: 0.5 + _heatCtrl.value * 0.5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.white
                        .withValues(alpha: 0.3 + _heatCtrl.value * 0.3),
                    blurRadius: 4,
                    spreadRadius: 1)
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text('Active Now',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  DESCRIPTION CARD
  // ════════════════════════════════════════════════════════════

  Widget _buildDescriptionCard() {
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
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.info_outline,
                  color: Color(0xFF2E7D32), size: 22),
            ),
            const SizedBox(width: 12),
            Text('Details',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
          ]),
          const SizedBox(height: 14),
          Text(widget.alert.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 15, height: 1.5, color: Colors.grey[800])),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  DO SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildDoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.check_circle,
                  color: Color(0xFF4CAF50), size: 26),
            ),
            const SizedBox(width: 12),
            Text('What to Do',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CAF50),
                    fontSize: 18)),
          ]),
          const SizedBox(height: 16),
          ...widget.alert.doList
              .asMap()
              .entries
              .map((e) => _buildListItem(e.value, true, e.key + 1)),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  DON'T SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildDontSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFF44336).withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFF44336).withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFF44336).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10)),
              child:
                  const Icon(Icons.cancel, color: Color(0xFFF44336), size: 26),
            ),
            const SizedBox(width: 12),
            Text('What NOT to Do',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF44336),
                    fontSize: 18)),
          ]),
          const SizedBox(height: 16),
          ...widget.alert.dontList
              .asMap()
              .entries
              .map((e) => _buildListItem(e.value, false, e.key + 1)),
        ]),
      ),
    );
  }

  Widget _buildListItem(String text, bool isDo, int number) {
    final color = isDo ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Center(
            child: Text('$number',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 15, height: 1.4)),
          ),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  ACTION BUTTONS
  // ════════════════════════════════════════════════════════════

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
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Acknowledge & Close',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () {
              HapticFeedback.mediumImpact();
              TtsService.instance.stop();
              Navigator.pop(context);
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
            icon: const Icon(Icons.home, color: Color(0xFF2E7D32)),
            label: const Text('Back to Home',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32))),
            onPressed: () {
              HapticFeedback.mediumImpact();
              TtsService.instance.stop();
              Navigator.pop(context);
            },
          ),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  TTS
  // ════════════════════════════════════════════════════════════

  Future<void> _speakAlertSummary() async {
    HapticFeedback.mediumImpact();
    final tts = TtsService.instance;
    final lang = tts.currentLanguage;
    final doText = widget.alert.doList.join('. ');
    final dontText = widget.alert.dontList.join('. ');
    final summaryEN =
        '${widget.alert.title}. ${widget.alert.severityText} severity alert. '
        '${widget.alert.description}. What to do: $doText. What NOT to do: $dontText.';
    final summaryHI =
        '${widget.alert.title}. ${_getSeverityInHindi(widget.alert.severity)} गंभीरता की चेतावनी. '
        '${widget.alert.description}. क्या करें: $doText. क्या न करें: $dontText.';
    await tts.speak(lang == TtsLanguages.hiIN ? summaryHI : summaryEN,
        languageCode: lang);
  }

  // ════════════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════════════

  String _getSeverityInHindi(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.low:
        return 'कम';
      case AlertSeverity.medium:
        return 'मध्यम';
      case AlertSeverity.high:
        return 'उच्च';
      case AlertSeverity.critical:
        return 'गंभीर';
    }
  }

  LinearGradient _getSeverityGradient(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.low:
        return const LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
      case AlertSeverity.medium:
        return const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFEF6C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
      case AlertSeverity.high:
      case AlertSeverity.critical:
        return const LinearGradient(
            colors: [Color(0xFFEF5350), Color(0xFFC62828)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);
    }
  }

  Color _getSeverityColor(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.low:
        return const Color(0xFF42A5F5);
      case AlertSeverity.medium:
        return const Color(0xFFFFA726);
      case AlertSeverity.high:
      case AlertSeverity.critical:
        return const Color(0xFFEF5350);
    }
  }

  IconData _getSeverityIcon(AlertSeverity s) {
    switch (s) {
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

enum _AlertCategory { rain, pest, heat, generic }

// ════════════════════════════════════════════════════════════════════
//  RAIN ANIMATION — contained in top 120px zone
// ════════════════════════════════════════════════════════════════════

class _RainAnimation extends StatelessWidget {
  final AnimationController controller;
  final AnimationController cropShake;
  const _RainAnimation({required this.controller, required this.cropShake});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, cropShake]),
      builder: (_, __) {
        return Stack(clipBehavior: Clip.hardEdge, children: [
          // Dark storm sky
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF37474F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Rain drops — constrained to top 120px only
          ...List.generate(22, (i) {
            final rand = (i * 37 % 100) / 100.0;
            final speed = 0.4 + (i % 5) * 0.12;
            final phase = (controller.value * speed + rand) % 1.0;
            final x = (i * 17 % 100) / 100.0;
            return Positioned(
              left: x * 380,
              top: phase * 130 - 14,
              child: Container(
                width: 2,
                height: 10 + (i % 4) * 3.0,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
          Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                final bendAngle =
                    sin(cropShake.value * pi * 2 + i * 0.8) * 0.16;
                return Transform(
                  transform: Matrix4.identity()
                    ..translateByDouble(12.0, 24.0, 0, 0)
                    ..rotateZ(bendAngle)
                    ..translateByDouble(-12.0, -24.0, 0, 0),
                  child: Text(
                    i == 2 ? '🌾' : '🌱',
                    style: const TextStyle(fontSize: 24),
                  ),
                );
              }),
            ),
          ),
        ]);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  PEST ANIMATION — contained in top 120px zone
// ════════════════════════════════════════════════════════════════════

class _PestAnimation extends StatelessWidget {
  final AnimationController controller;
  const _PestAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Stack(clipBehavior: Clip.hardEdge, children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF558B2F), Color(0xFF33691E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Dirt strip at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: 22, color: const Color(0xFF5D4037)),
          ),
          // Crop row — with progressive "eating" effect
          Positioned(
            bottom: 22,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (i) {
                final eat = ((controller.value * 0.7 + i * 0.17) % 1.0);
                final emoji = eat > 0.6
                    ? '🥀'
                    : eat > 0.3
                        ? '🌿'
                        : '🌾';
                return Text(emoji, style: const TextStyle(fontSize: 24));
              }),
            ),
          ),
          // Bugs crawling (2 lanes, clipped inside 120px)
          ...List.generate(4, (i) {
            final speed = 0.28 + (i % 2) * 0.14;
            final phase = (controller.value * speed + i * 0.25) % 1.0;
            final y = 14.0 + (i % 2) * 32.0;
            const bugs = ['🐛', '🐜', '🦗', '🐛'];
            return Positioned(
              left: phase * 400 - 22,
              top: y,
              child: Text(bugs[i], style: const TextStyle(fontSize: 18)),
            );
          }),
        ]);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  HEAT ANIMATION — contained in top 120px zone
// ════════════════════════════════════════════════════════════════════

class _HeatAnimation extends StatelessWidget {
  final AnimationController controller;
  const _HeatAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final pulse = controller.value;
        return Stack(clipBehavior: Clip.hardEdge, children: [
          // Sky
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                      const Color(0xFFFF8F00), const Color(0xFFD84315), pulse)!,
                  Color.lerp(
                      const Color(0xFFFFCC02), const Color(0xFFFF6E40), pulse)!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Pulsing sun (right side, within top zone)
          Positioned(
            top: 8 - pulse * 4,
            right: 36,
            child: Container(
              width: 48 + pulse * 12,
              height: 48 + pulse * 12,
              decoration: BoxDecoration(
                color: Colors.yellow.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.35 + pulse * 0.25),
                    blurRadius: 16 + pulse * 16,
                    spreadRadius: 3 + pulse * 6,
                  ),
                ],
              ),
              child: const Center(
                  child: Text('☀️', style: TextStyle(fontSize: 24))),
            ),
          ),
          // Heat shimmer lines rising
          ...List.generate(5, (i) {
            final shimmerPhase = (controller.value * 0.75 + i * 0.20) % 1.0;
            return Positioned(
              bottom: 20 + shimmerPhase * 80,
              left: 24.0 + i * 58,
              child: Opacity(
                opacity: (1.0 - shimmerPhase) * 0.55,
                child: Container(
                  width: 2,
                  height: 16 + (i % 3) * 6.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            );
          }),
          // Parched ground strip
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 22,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD7CCC8), Color(0xFFA1887F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Stressed farmer + wilted crops in bottom strip
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('🥀', style: TextStyle(fontSize: 20)),
                Text(pulse > 0.6 ? '😰' : '😓',
                    style: TextStyle(fontSize: 24 + pulse * 3)),
                const Text('🥀', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          // Temp badge
          Positioned(
            top: 10,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade800.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('🌡️', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 3),
                Text(
                  '${(38 + pulse * 6).toInt()}°C',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12),
                ),
              ]),
            ),
          ),
        ]);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  GENERIC ANIMATION
// ════════════════════════════════════════════════════════════════════

class _GenericAlertAnimation extends StatelessWidget {
  final AnimationController controller;
  final String icon;
  const _GenericAlertAnimation({required this.controller, required this.icon});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Stack(clipBehavior: Clip.hardEdge, children: [
          Center(
            child: Container(
              width: 70 + controller.value * 50,
              height: 70 + controller.value * 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 1.0 - controller.value),
                  width: 2,
                ),
              ),
            ),
          ),
          Center(
            child: Text(icon,
                style: TextStyle(fontSize: 46 + controller.value * 6)),
          ),
        ]);
      },
    );
  }
}
