library;

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/task_model.dart';
import '../../../services/localization/tts_service.dart';

class TaskDetailsPage extends StatefulWidget {
  final TaskModel task;
  const TaskDetailsPage({super.key, required this.task});
  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage>
    with TickerProviderStateMixin {
  late TaskModel task;
  static const String speakId = 'taskdetailpage';

  // Reminder state
  DateTime? reminderTime;
  bool reminderSet = false;

  // Step completion tracking
  late List<bool> stepsDone;

  // ── Animation Controllers ──────────────────────────────────────
  late final AnimationController headerPulseController;
  late final AnimationController completionController;
  late final AnimationController _mainAnim;
  late final AnimationController _floatAnim;
  late final AnimationController _entryAnim;

  bool showSuccessOverlay = false;

  // Countdown timer display
  Timer? countdownTimer;
  Duration timeUntilDue = Duration.zero;

  @override
  void initState() {
    super.initState();
    task = widget.task;
    stepsDone = List.filled(task.instructions.length, false);

    headerPulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);

    completionController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _mainAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();

    _floatAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300))
      ..repeat(reverse: true);

    _entryAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();

    startCountdown();
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    headerPulseController.dispose();
    completionController.dispose();
    _mainAnim.dispose();
    _floatAnim.dispose();
    _entryAnim.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  // ── Countdown ─────────────────────────────────────────────────
  void startCountdown() {
    timeUntilDue = task.dueTime.difference(DateTime.now());
    countdownTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() => timeUntilDue = task.dueTime.difference(DateTime.now()));
      }
    });
  }

  // ── Progress ──────────────────────────────────────────────────
  int get completedSteps => stepsDone.where((s) => s).length;
  double get progress =>
      stepsDone.isEmpty ? 0 : completedSteps / stepsDone.length;

  // ── TTS ───────────────────────────────────────────────────────
  String get speakText {
    final dueStr =
        '${task.dueTime.hour}:${task.dueTime.minute.toString().padLeft(2, '0')}';
    final steps = task.instructions
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('. ');
    if (TtsService.instance.isHindi) {
      return '${task.title}. फसल ${task.cropName}, ${task.fieldSizeText}.'
          '${task.isOverdue ? 'यह कार्य विलंबित है।' : 'समय $dueStr।'}'
          '${task.quantity != null ? 'आवश्यक मात्रा ${task.quantity}।' : ''}'
          'निर्देश: $steps';
    }
    return 'Task ${task.title}. Crop ${task.cropName}, ${task.fieldSizeText}.'
        '${task.isOverdue ? 'This task is overdue.' : 'Due at $dueStr.'}'
        '${task.quantity != null ? 'Required quantity ${task.quantity}.' : ''}'
        'Instructions: $steps';
  }

  // ── Countdown label ───────────────────────────────────────────
  String get countdownLabel {
    if (task.isOverdue) return 'Overdue';
    if (timeUntilDue.isNegative) return 'Overdue';
    final h = timeUntilDue.inHours;
    final m = timeUntilDue.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m left';
    if (m > 0) return '${m}m left';
    return 'Due now';
  }

  // ── Header gradient colours ───────────────────────────────────
  Color get headerTopColor {
    if (task.isOverdue) return const Color(0xFFD32F2F);
    if (timeUntilDue.inHours < 2) return const Color(0xFFE64A19);
    return _categoryTopColor;
  }

  Color get headerBottomColor {
    if (task.isOverdue) return const Color(0xFFFF6B35);
    if (timeUntilDue.inHours < 2) return const Color(0xFFFFA726);
    return _categoryBottomColor;
  }

  // ── Category detection (title-only, no .category field) ───────
  _TaskAnimCategory get _animCategory {
    final t = task.title.toLowerCase();
    if (t.contains('irrigat') || t.contains('water') || t.contains('drip')) {
      return _TaskAnimCategory.irrigation;
    }
    if (t.contains('fertiliz') ||
        t.contains('nutrient') ||
        t.contains('urea') ||
        t.contains('npk')) {
      return _TaskAnimCategory.fertilizing;
    }
    if (t.contains('harvest') ||
        t.contains('reap') ||
        t.contains('collect') ||
        t.contains('cut crop') ||
        t.contains('cutting')) {
      return _TaskAnimCategory.harvesting;
    }
    if (t.contains('pest') ||
        t.contains('weed') ||
        t.contains('fungic') ||
        t.contains('insect') ||
        t.contains('disease') ||
        t.contains('spray')) {
      return _TaskAnimCategory.pestControl;
    }
    if (t.contains('plough') ||
        t.contains('till') ||
        t.contains('soil') ||
        t.contains('plow') ||
        t.contains('land prep')) {
      return _TaskAnimCategory.ploughing;
    }
    if (t.contains('sow') ||
        t.contains('plant') ||
        t.contains('seed') ||
        t.contains('transplant') ||
        t.contains('nursery')) {
      return _TaskAnimCategory.sowing;
    }
    return _TaskAnimCategory.general;
  }

  Color get _categoryTopColor {
    switch (_animCategory) {
      case _TaskAnimCategory.irrigation:
        return const Color(0xFF0288D1);
      case _TaskAnimCategory.fertilizing:
        return const Color(0xFF558B2F);
      case _TaskAnimCategory.harvesting:
        return const Color(0xFFF9A825);
      case _TaskAnimCategory.pestControl:
        return const Color(0xFF6A1B9A);
      case _TaskAnimCategory.ploughing:
        return const Color(0xFF795548);
      case _TaskAnimCategory.sowing:
        return const Color(0xFF2E7D32);
      case _TaskAnimCategory.general:
        return const Color(0xFF1B5E20);
    }
  }

  Color get _categoryBottomColor {
    switch (_animCategory) {
      case _TaskAnimCategory.irrigation:
        return const Color(0xFF01579B);
      case _TaskAnimCategory.fertilizing:
        return const Color(0xFF33691E);
      case _TaskAnimCategory.harvesting:
        return const Color(0xFFE65100);
      case _TaskAnimCategory.pestControl:
        return const Color(0xFF4A148C);
      case _TaskAnimCategory.ploughing:
        return const Color(0xFF4E342E);
      case _TaskAnimCategory.sowing:
        return const Color(0xFF1B5E20);
      case _TaskAnimCategory.general:
        return const Color(0xFF388E3C);
    }
  }

  String get _categoryEmoji {
    switch (_animCategory) {
      case _TaskAnimCategory.irrigation:
        return '💧';
      case _TaskAnimCategory.fertilizing:
        return '🌿';
      case _TaskAnimCategory.harvesting:
        return '🚜';
      case _TaskAnimCategory.pestControl:
        return '🛡️';
      case _TaskAnimCategory.ploughing:
        return '⚙️';
      case _TaskAnimCategory.sowing:
        return '🌱';
      case _TaskAnimCategory.general:
        return '🌾';
    }
  }

  String get _categoryLabel {
    switch (_animCategory) {
      case _TaskAnimCategory.irrigation:
        return 'Irrigation';
      case _TaskAnimCategory.fertilizing:
        return 'Fertilizing';
      case _TaskAnimCategory.harvesting:
        return 'Harvesting';
      case _TaskAnimCategory.pestControl:
        return 'Pest Control';
      case _TaskAnimCategory.ploughing:
        return 'Ploughing';
      case _TaskAnimCategory.sowing:
        return 'Sowing';
      case _TaskAnimCategory.general:
        return 'Farm Task';
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F0),
      body: Stack(
        children: [
          Column(
            children: [
              // ── 1. Top bar with screen name ─────────────────
              _buildTopBar(context),
              // ── 2. Animated hero canvas ─────────────────────
              _buildAnimatedHeroSection(isCompleted),
              // ── 3. Scrollable body ──────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 40),
                  child: Column(
                    children: [
                      _buildInfoStrip(context),
                      const SizedBox(height: 16),
                      _buildReminderCard(context),
                      const SizedBox(height: 16),
                      if (task.quantity != null) ...[
                        _buildQuantityCard(context),
                        const SizedBox(height: 16),
                      ],
                      if (!isCompleted) ...[
                        _buildProgressCard(context),
                        const SizedBox(height: 16),
                      ],
                      _buildInstructionsSection(context, isCompleted),
                      const SizedBox(height: 16),
                      if (task.videoUrl != null) ...[
                        _buildVideoCard(context),
                        const SizedBox(height: 16),
                      ],
                      _buildActionButtons(context, isCompleted),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (showSuccessOverlay) _buildSuccessOverlay(context),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  TOP BAR  — screen name row (matches other pages)
  // ════════════════════════════════════════════════════════════════

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: headerTopColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        left: 8,
        right: 8,
        bottom: 10,
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 4),
          // Screen name + task subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // TOP ROW: pulsing dot + label + category pill
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: headerPulseController,
                      builder: (_, __) => Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                              alpha: 0.5 + headerPulseController.value * 0.5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(
                                  alpha:
                                      0.3 + headerPulseController.value * 0.3),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Text(
                      "TODAY'S TASK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$_categoryEmoji $_categoryLabel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // BOTTOM: task name as subtitle
                Text(
                  task.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Voice button
          _buildVoiceButton(),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  ANIMATED HERO SECTION  — fixed 175px canvas, no overlap
  // ════════════════════════════════════════════════════════════════

  Widget _buildAnimatedHeroSection(bool isCompleted) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_mainAnim, _floatAnim, _entryAnim, headerPulseController]),
      builder: (_, __) {
        return Container(
          width: double.infinity,
          height: 175,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [headerTopColor, headerBottomColor],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: headerTopColor.withValues(alpha: 0.35),
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
            child: Stack(
              children: [
                // Layer 1: category animation fills canvas
                Positioned.fill(child: _buildCategoryAnimation()),

                // Layer 2: bottom gradient + task info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _entryAnim,
                        curve: Curves.easeOut,
                      )),
                      child: FadeTransition(
                        opacity: _entryAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Crop + field size
                            Row(children: [
                              const Icon(Icons.local_florist,
                                  color: Colors.white70, size: 13),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${task.cropName}  •  ${task.fieldSizeText}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  CATEGORY ANIMATIONS
  // ════════════════════════════════════════════════════════════════

  Widget _buildCategoryAnimation() {
    switch (_animCategory) {
      case _TaskAnimCategory.irrigation:
        return _buildIrrigationAnimation();
      case _TaskAnimCategory.fertilizing:
        return _buildFertilizingAnimation();
      case _TaskAnimCategory.harvesting:
        return _buildHarvestingAnimation();
      case _TaskAnimCategory.pestControl:
        return _buildPestControlAnimation();
      case _TaskAnimCategory.ploughing:
        return _buildPloughingAnimation();
      case _TaskAnimCategory.sowing:
        return _buildSowingAnimation();
      case _TaskAnimCategory.general:
        return _buildGeneralAnimation();
    }
  }

  // ── 💧 IRRIGATION ─────────────────────────────────────────────
  Widget _buildIrrigationAnimation() {
    return Stack(children: [
      ...List.generate(4, (i) {
        final phase = (_mainAnim.value + i * 0.25) % 1.0;
        return Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 30 + phase * 340,
              height: 30 + phase * 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.lightBlueAccent
                      .withValues(alpha: (1.0 - phase) * 0.35),
                  width: 1.5,
                ),
              ),
            ),
          ),
        );
      }),
      ...List.generate(14, (i) {
        final speed = 0.5 + (i % 4) * 0.12;
        final phase = (_mainAnim.value * speed + i * 0.073) % 1.0;
        final x = (i * 27 % 360).toDouble();
        return Positioned(
          left: x,
          top: phase * 280 - 20,
          child: Opacity(
            opacity: (1.0 - phase) * 0.85,
            child: Text(
              i % 3 == 0 ? '💧' : '•',
              style: TextStyle(
                  fontSize: i % 3 == 0 ? 13 : 8,
                  color: Colors.lightBlueAccent.withValues(alpha: 0.8)),
            ),
          ),
        );
      }),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 36,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      ...List.generate(5, (i) {
        final bob = sin(_floatAnim.value * pi + i * 0.9) * 3;
        return Positioned(
          bottom: 34,
          left: 20.0 + i * 72,
          child: Transform.translate(
            offset: Offset(0, bob),
            child: Text(
              i % 2 == 0 ? '🌾' : '🌱',
              style: const TextStyle(fontSize: 26),
            ),
          ),
        );
      }),
      Positioned(
        bottom: 36,
        left: 0,
        right: 0,
        child: CustomPaint(
          size: const Size(double.infinity, 8),
          painter: _WaterFlowPainter(_mainAnim.value),
        ),
      ),
    ]);
  }

  // ── 🌿 FERTILIZING ────────────────────────────────────────────
  Widget _buildFertilizingAnimation() {
    return Stack(children: [
      ...List.generate(18, (i) {
        final phase = (_mainAnim.value * 0.6 + i * 0.058) % 1.0;
        final startX = 10.0 + (i % 5) * 20;
        final driftX = startX + phase * 180 + (i % 3) * 20;
        final driftY = 180 - phase * 160 + sin(phase * pi) * 20;
        return Positioned(
          left: driftX,
          top: driftY,
          child: Opacity(
            opacity: (1.0 - phase) * 0.7,
            child: Container(
              width: 5 + (i % 3) * 3.0,
              height: 5 + (i % 3) * 3.0,
              decoration: BoxDecoration(
                color: i % 3 == 0
                    ? Colors.greenAccent.withValues(alpha: 0.7)
                    : i % 3 == 1
                        ? Colors.lightGreen.withValues(alpha: 0.6)
                        : Colors.yellow.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
      Positioned(
        bottom: 50,
        left: (_mainAnim.value * 280) % 280,
        child: const Text('🔫', style: TextStyle(fontSize: 26)),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 38,
          color: const Color(0xFF4E342E).withValues(alpha: 0.9),
        ),
      ),
      ...List.generate(5, (i) {
        final scale = 0.85 + _floatAnim.value * 0.2;
        return Positioned(
          bottom: 36,
          left: 16.0 + i * 68,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.bottomCenter,
            child: Text(
              i % 2 == 0 ? '🌿' : '🌾',
              style: const TextStyle(fontSize: 26),
            ),
          ),
        );
      }),
    ]);
  }

  // ── 🚜 HARVESTING ─────────────────────────────────────────────
  Widget _buildHarvestingAnimation() {
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF9C4), Color(0xFFFFB300)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      ...List.generate(18, (i) {
        final phase = (_mainAnim.value * 0.65 + i * 0.058) % 1.0;
        return Positioned(
          left: (i * 21 % 360).toDouble(),
          top: phase * 280 - 20,
          child: Opacity(
            opacity: (1.0 - phase),
            child: Text(
              i % 4 == 0
                  ? '🌾'
                  : i % 4 == 1
                      ? '✨'
                      : i % 4 == 2
                          ? '⭐'
                          : '🌽',
              style: TextStyle(fontSize: 10 + (i % 3) * 5.0),
            ),
          ),
        );
      }),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 40,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8BC34A), Color(0xFF558B2F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 10,
        left: _mainAnim.value * 310 - 50,
        child: const Text('🚜', style: TextStyle(fontSize: 38)),
      ),
      ...List.generate(6, (i) {
        final behindTractor = _mainAnim.value * 310 - 60 > i * 55.0;
        return Positioned(
          bottom: 38,
          left: i * 55.0,
          child: Text(
            behindTractor ? '🌾' : '🌿',
            style: const TextStyle(fontSize: 22),
          ),
        );
      }),
    ]);
  }

  // ── 🛡️ PEST CONTROL ──────────────────────────────────────────
  Widget _buildPestControlAnimation() {
    return Stack(children: [
      ...List.generate(5, (i) {
        final speed = 0.3 + i * 0.08;
        final phase = (_mainAnim.value * speed + i * 0.22) % 1.0;
        const bugs = ['🐛', '🐜', '🦗', '🐛', '🦟'];
        final eliminated = phase > 0.55;
        return Positioned(
          left: phase * 400 - 20,
          top: 60.0 + i * 30,
          child: Opacity(
            opacity: eliminated ? 0 : 1,
            child: Text(bugs[i], style: const TextStyle(fontSize: 22)),
          ),
        );
      }),
      ...List.generate(5, (i) {
        final speed = 0.3 + i * 0.08;
        final phase = (_mainAnim.value * speed + i * 0.22) % 1.0;
        if (phase > 0.55 && phase < 0.65) {
          return Positioned(
            left: phase * 400 - 20,
            top: 60.0 + i * 30,
            child: Text(
              '💥',
              style: TextStyle(fontSize: 16 + (0.65 - phase) / 0.1 * 8),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
      Positioned(
        top: 50,
        left: 0,
        right: 0,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 68 + _floatAnim.value * 12,
                height: 68 + _floatAnim.value * 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.purpleAccent
                        .withValues(alpha: 0.4 - _floatAnim.value * 0.2),
                    width: 2,
                  ),
                ),
              ),
              const Text('🛡️', style: TextStyle(fontSize: 44)),
            ],
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 40,
          color: const Color(0xFF388E3C).withValues(alpha: 0.8),
        ),
      ),
      ...List.generate(
          6,
          (i) => Positioned(
                bottom: 38,
                left: 10.0 + i * 60,
                child: const Text('🌿', style: TextStyle(fontSize: 22)),
              )),
      Positioned(
        top: 14,
        right: 14,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.purple.shade700.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🛡️', style: TextStyle(fontSize: 12)),
              SizedBox(width: 4),
              Text('PROTECTED',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    ]);
  }

  // ── ⚙️ PLOUGHING ──────────────────────────────────────────────
  Widget _buildPloughingAnimation() {
    return Stack(children: [
      Container(color: const Color(0xFF5D4037)),
      ...List.generate(5, (i) {
        final offset = (_mainAnim.value * 60 + i * 52.0) % 260;
        return Positioned(
          top: offset,
          left: 0,
          right: 0,
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF8D6E63).withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      }),
      ...List.generate(12, (i) {
        final phase = (_mainAnim.value * 0.7 + i * 0.087) % 1.0;
        final arc = sin(phase * pi);
        return Positioned(
          left: (i * 31 % 360).toDouble(),
          bottom: 30 + arc * 90,
          child: Opacity(
            opacity: arc * 0.9,
            child: Container(
              width: 5 + (i % 3) * 3.0,
              height: 5 + (i % 3) * 3.0,
              decoration: BoxDecoration(
                color: const Color(0xFFA1887F).withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
      Positioned(
        bottom: 18,
        left: _mainAnim.value * 310 - 40,
        child: const Text('⚙️', style: TextStyle(fontSize: 32)),
      ),
      Positioned(
        bottom: 16,
        left: _mainAnim.value * 310 - 72,
        child: Text(
          _floatAnim.value > 0.5 ? '🧑‍🌾' : '👨‍🌾',
          style: const TextStyle(fontSize: 28),
        ),
      ),
      Positioned(
        top: 14,
        left: 14,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.brown.shade700.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('⚙️ Tilling Soil',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11)),
        ),
      ),
    ]);
  }

  // ── 🌱 SOWING ─────────────────────────────────────────────────
  Widget _buildSowingAnimation() {
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF81C784), Color(0xFF388E3C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      ...List.generate(10, (i) {
        final phase = (_mainAnim.value * 0.8 + i * 0.1) % 1.0;
        return Positioned(
          left: 140.0 + sin(phase * pi * 2 + i) * 50,
          top: 30 + phase * 180,
          child: Opacity(
            opacity: (1.0 - phase),
            child: Text(
              i % 2 == 0 ? '🌰' : '•',
              style: TextStyle(
                  fontSize: i % 2 == 0 ? 12 : 6,
                  color: const Color(0xFF8D6E63)),
            ),
          ),
        );
      }),
      Positioned(
        top: 14,
        left: 0,
        right: 0,
        child: Center(
          child: Transform.translate(
            offset: Offset(0, -3 + _floatAnim.value * 6),
            child: const Text('🎒', style: TextStyle(fontSize: 34)),
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(height: 42, color: const Color(0xFF5D4037)),
      ),
      ...List.generate(6, (i) {
        final sproutPhase = (_mainAnim.value * 0.5 + i * 0.18) % 1.0;
        final height = 8.0 + sproutPhase * 20;
        final emoji = sproutPhase > 0.6
            ? '🌱'
            : sproutPhase > 0.3
                ? '🌿'
                : '🌰';
        return Positioned(
          bottom: 40,
          left: 15.0 + i * 60,
          child: Text(emoji, style: TextStyle(fontSize: height)),
        );
      }),
      Positioned(
        top: 62,
        left: 14,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('🌱 Sowing Seeds',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11)),
        ),
      ),
    ]);
  }

  // ── 🌾 GENERAL ────────────────────────────────────────────────
  Widget _buildGeneralAnimation() {
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      Positioned(
        top: 10 - _floatAnim.value * 6,
        right: 24,
        child: Container(
          width: 48 + _floatAnim.value * 8,
          height: 48 + _floatAnim.value * 8,
          decoration: BoxDecoration(
            color: Colors.yellow.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange
                    .withValues(alpha: 0.3 + _floatAnim.value * 0.3),
                blurRadius: 16 + _floatAnim.value * 12,
                spreadRadius: 4,
              ),
            ],
          ),
          child:
              const Center(child: Text('☀️', style: TextStyle(fontSize: 24))),
        ),
      ),
      ...List.generate(3, (i) {
        final phase = (_mainAnim.value + i * 0.33) % 1.0;
        return Positioned(
          top: 14 - phase * 20,
          right: 28 - phase * 30,
          child: Container(
            width: 40 + phase * 80,
            height: 40 + phase * 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.yellow.withValues(alpha: (1.0 - phase) * 0.25),
                width: 1.5,
              ),
            ),
          ),
        );
      }),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2E7D32).withValues(alpha: 0.8),
                const Color(0xFF1B5E20),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      ...List.generate(6, (i) {
        final sway = sin(_mainAnim.value * 2 * pi + i * 0.7) * 0.1;
        return Positioned(
          bottom: 38,
          left: 10.0 + i * 60,
          child: Transform(
            transform: Matrix4.identity()
              ..translateByDouble(14.0, 26.0, 0, 1.0)
              ..rotateZ(sway)
              ..translateByDouble(-14.0, -26.0, 0, 1.0),
            child: Text(
              i % 2 == 0 ? '🌾' : '🌿',
              style: const TextStyle(fontSize: 26),
            ),
          ),
        );
      }),
      Positioned(
        bottom: 36,
        left: (_mainAnim.value * 260) % 320,
        child: Text(
          _floatAnim.value > 0.5 ? '🧑‍🌾' : '👨‍🌾',
          style: const TextStyle(fontSize: 28),
        ),
      ),
    ]);
  }
  // ════════════════════════════════════════════════════════════════
  //  VOICE BUTTON
  // ════════════════════════════════════════════════════════════════

  Widget _buildVoiceButton() {
    return ValueListenableBuilder<String?>(
      valueListenable: TtsService.instance.currentSpeakId,
      builder: (context, activeId, _) {
        final isSpeaking = activeId == speakId;
        return GestureDetector(
          onTap: () async {
            HapticFeedback.mediumImpact();
            if (isSpeaking) {
              await TtsService.instance.stop();
            } else {
              await TtsService.instance.speak(speakText, speakId: speakId);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isSpeaking
                  ? Colors.white.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: isSpeaking ? 0.9 : 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  INFO STRIP
  // ════════════════════════════════════════════════════════════════

  Widget _buildInfoStrip(BuildContext context) {
    final dueStr =
        '${task.dueTime.hour}:${task.dueTime.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${task.dueTime.day}/${task.dueTime.month}/${task.dueTime.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Expanded(
          child: _buildInfoChip(
              icon: Icons.calendar_today,
              label: 'Date',
              value: dateStr,
              color: const Color(0xFF1565C0)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildInfoChip(
              icon: Icons.access_time_filled,
              label: 'Due Time',
              value: dueStr,
              color: const Color(0xFF6A1B9A)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildInfoChip(
              icon: Icons.format_list_numbered,
              label: 'Steps',
              value: '${task.instructions.length}',
              color: const Color(0xFF2E7D32)),
        ),
      ]),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  REMINDER CARD
  // ════════════════════════════════════════════════════════════════

  Widget _buildReminderCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: reminderSet
              ? const Color(0xFF1565C0).withValues(alpha: 0.07)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: reminderSet
                ? const Color(0xFF1565C0).withValues(alpha: 0.5)
                : Colors.grey.shade200,
            width: reminderSet ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: reminderSet
                  ? const Color(0xFF1565C0).withValues(alpha: 0.12)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              reminderSet
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: reminderSet ? const Color(0xFF1565C0) : Colors.grey[500],
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminderSet ? 'Reminder Set' : 'Set Reminder',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: reminderSet
                          ? const Color(0xFF1565C0)
                          : Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  reminderSet && reminderTime != null
                      ? '${reminderTime!.day}/${reminderTime!.month} at ${reminderTime!.hour}:${reminderTime!.minute.toString().padLeft(2, '0')}'
                      : 'Tap to get notified before this task',
                  style: TextStyle(
                      fontSize: 12,
                      color: reminderSet
                          ? const Color(0xFF1565C0)
                          : Colors.grey[500]),
                ),
              ],
            ),
          ),
          if (reminderSet)
            Row(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(
                onTap: () => _showReminderPicker(context),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit,
                      color: Color(0xFF1565C0), size: 16),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    reminderSet = false;
                    reminderTime = null;
                  });
                  _showSnack(context, 'Reminder cancelled', Colors.grey);
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.close, color: AppColors.errorRed, size: 16),
                ),
              ),
            ])
          else
            GestureDetector(
              onTap: () => _showReminderPicker(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Set',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  QUANTITY CARD
  // ════════════════════════════════════════════════════════════════

  Widget _buildQuantityCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.accentYellow.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: AppColors.accentYellow.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.scale, color: AppColors.accentYellow, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Required Quantity',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Text(task.quantity!,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accentYellow)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.accentYellow.withValues(alpha: 0.3)),
            ),
            child: Text('Materials Ready?',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentYellow)),
          ),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  PROGRESS CARD
  // ════════════════════════════════════════════════════════════════

  Widget _buildProgressCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Task Progress',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('$completedSteps/${stepsDone.length} steps',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0
                      ? AppColors.successGreen
                      : AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              progress == 0
                  ? 'Tap steps below to mark them done'
                  : progress >= 1.0
                      ? '✓ All steps complete! Tap Mark as Completed'
                      : '${(progress * 100).toInt()}% done — keep going!',
              style: TextStyle(
                fontSize: 11,
                color:
                    progress >= 1.0 ? AppColors.successGreen : Colors.grey[500],
                fontWeight: progress >= 1.0 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  INSTRUCTIONS SECTION
  // ════════════════════════════════════════════════════════════════

  Widget _buildInstructionsSection(BuildContext context, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.format_list_numbered,
                  color: AppColors.primaryGreen, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Step-by-Step Instructions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (!isCompleted)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final allDone = stepsDone.every((s) => s);
                  setState(() {
                    stepsDone = List.filled(stepsDone.length, !allDone);
                  });
                },
                child: Text(
                  stepsDone.every((s) => s) ? 'Reset All' : 'Mark All',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700),
                ),
              ),
          ]),
          const SizedBox(height: 14),
          ...List.generate(
            task.instructions.length,
            (index) => _buildInstructionStep(
                context, index, task.instructions[index], isCompleted),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(
      BuildContext context, int index, String instruction, bool taskCompleted) {
    final isDone = taskCompleted || stepsDone[index];
    final stepNum = index + 1;
    return GestureDetector(
      onTap: taskCompleted
          ? null
          : () {
              HapticFeedback.selectionClick();
              setState(() => stepsDone[index] = !stepsDone[index]);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDone
              ? AppColors.successGreen.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone
                ? AppColors.successGreen.withValues(alpha: 0.5)
                : Colors.grey.shade200,
            width: isDone ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDone ? AppColors.successGreen : AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text('$stepNum',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step $stepNum',
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            isDone ? AppColors.successGreen : Colors.grey[400],
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    instruction,
                    style: TextStyle(
                        fontSize: 14,
                        color: isDone ? Colors.grey[500] : Colors.black87,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.grey[400],
                        height: 1.4),
                  ),
                ],
              ),
            ),
            if (!taskCompleted)
              Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? AppColors.successGreen : Colors.grey.shade300,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  VIDEO CARD
  // ════════════════════════════════════════════════════════════════

  Widget _buildVideoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.accentBlue.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: AppColors.accentBlue.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_circle_filled,
                color: AppColors.accentBlue, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Video Guide Available',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                SizedBox(height: 3),
                Text('Watch step-by-step tutorial',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.accentBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Watch',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  ACTION BUTTONS
  // ════════════════════════════════════════════════════════════════

  Widget _buildActionButtons(BuildContext context, bool isCompleted) {
    if (isCompleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.successGreen.withValues(alpha: 0.4),
                width: 1.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.successGreen, size: 28),
              SizedBox(width: 10),
              Text('Task Completed! 🎉',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.successGreen)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
            icon: const Icon(Icons.check_circle, size: 22),
            label: const Text('Mark as Completed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            onPressed: () {
              HapticFeedback.heavyImpact();
              _markAsCompleted(context);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.accentOrange),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(Icons.snooze, color: AppColors.accentOrange, size: 18),
              label: Text('Snooze',
                  style: TextStyle(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w700)),
              onPressed: () {
                HapticFeedback.lightImpact();
                _showSnoozeOptions(context);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.errorRed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(Icons.report_problem,
                  color: AppColors.errorRed, size: 18),
              label: Text('Report',
                  style: TextStyle(
                      color: AppColors.errorRed, fontWeight: FontWeight.w700)),
              onPressed: () {
                HapticFeedback.lightImpact();
                _reportIssue(context);
              },
            ),
          ),
        ]),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  SUCCESS OVERLAY
  // ════════════════════════════════════════════════════════════════

  Widget _buildSuccessOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                const Text('Task Done!',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.successGreen)),
                const SizedBox(height: 8),
                Text(
                  TtsService.instance.isHindi
                      ? 'शाबाश! बढ़िया काम, किसान! 🌾'
                      : 'Great work, farmer! Keep it up. 🌾',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  REMINDER PICKER
  // ════════════════════════════════════════════════════════════════

  void _showReminderPicker(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ReminderPickerSheet(
        task: task,
        currentReminder: reminderTime,
        onReminderSet: (dt) {
          setState(() {
            reminderTime = dt;
            reminderSet = true;
          });
          _showSnack(
            context,
            TtsService.instance.isHindi
                ? '${dt.hour}:${dt.minute.toString().padLeft(2, '0')} पर याद दिलाया जाएगा'
                : 'Reminder set for ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}',
            const Color(0xFF1565C0),
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  SNOOZE OPTIONS
  // ════════════════════════════════════════════════════════════════

  void _showSnoozeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Icon(Icons.snooze, color: AppColors.accentOrange),
                const SizedBox(width: 10),
                const Text('Snooze Task',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 8),
            const Divider(),
            ...[
              ('30 minutes', 30),
              ('1 Hour', 60),
              ('2 Hours', 120),
              ('Tomorrow Morning 6 AM', -1),
            ].map((option) => ListTile(
                  leading:
                      Icon(Icons.access_time, color: AppColors.accentOrange),
                  title: Text(option.$1,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    HapticFeedback.mediumImpact();
                    final snoozeUntil = option.$2 == -1
                        ? DateTime(DateTime.now().year, DateTime.now().month,
                            DateTime.now().day + 1, 6, 0)
                        : DateTime.now().add(Duration(minutes: option.$2));
                    setState(() {
                      task = task.copyWith(
                          status: TaskStatus.snoozed, dueTime: snoozeUntil);
                      reminderSet = false;
                      reminderTime = null;
                      startCountdown();
                    });
                    _showSnack(
                      context,
                      'Snoozed until ${snoozeUntil.hour}:${snoozeUntil.minute.toString().padLeft(2, '0')}',
                      AppColors.accentOrange,
                    );
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  MARK COMPLETED
  // ════════════════════════════════════════════════════════════════

  void _markAsCompleted(BuildContext context) {
    final navigator = Navigator.of(context);
    TtsService.instance.stop();
    setState(() {
      task = task.copyWith(
          status: TaskStatus.completed, completedAt: DateTime.now());
      stepsDone = List.filled(stepsDone.length, true);
      showSuccessOverlay = true;
    });
    TtsService.instance.speak(
      TtsService.instance.isHindi
          ? 'बधाई! कार्य पूर्ण हो गया।'
          : 'Congratulations! Task marked as completed.',
      speakId: speakId,
    );
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() => showSuccessOverlay = false);
        navigator.pop();
      }
    });
  }

  // ════════════════════════════════════════════════════════════════
  //  REPORT ISSUE
  // ════════════════════════════════════════════════════════════════

  void _reportIssue(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Report Issue'),
        content: const Text('What problem did you encounter with this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (mounted) {
                messenger.showSnackBar(const SnackBar(
                  content: Text("Issue reported. We'll look into it."),
                ));
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  SNACK HELPER
  // ════════════════════════════════════════════════════════════════

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }
}

// ════════════════════════════════════════════════════════════════════
//  CATEGORY ENUM
// ════════════════════════════════════════════════════════════════════

enum _TaskAnimCategory {
  irrigation,
  fertilizing,
  harvesting,
  pestControl,
  ploughing,
  sowing,
  general,
}

// ════════════════════════════════════════════════════════════════════
//  WATER FLOW CUSTOM PAINTER
// ════════════════════════════════════════════════════════════════════

class _WaterFlowPainter extends CustomPainter {
  final double animValue;
  _WaterFlowPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.lightBlueAccent.withValues(alpha: 0.55)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 +
          sin((x / size.width * 4 * pi) + animValue * 2 * pi) * 3;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaterFlowPainter old) => old.animValue != animValue;
}

// ════════════════════════════════════════════════════════════════════
//  REMINDER PICKER SHEET
// ════════════════════════════════════════════════════════════════════

class ReminderPickerSheet extends StatefulWidget {
  final TaskModel task;
  final DateTime? currentReminder;
  final ValueChanged<DateTime> onReminderSet;
  const ReminderPickerSheet({
    super.key,
    required this.task,
    required this.currentReminder,
    required this.onReminderSet,
  });
  @override
  State<ReminderPickerSheet> createState() => _ReminderPickerSheetState();
}

class _ReminderPickerSheetState extends State<ReminderPickerSheet> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  int selectedQuickIndex = -1;

  final List<_QuickReminder> quickOptions = const [
    _QuickReminder('30 min before', -30),
    _QuickReminder('1 hour before', -60),
    _QuickReminder('2 hours before', -120),
    _QuickReminder('1 day before', -1440),
    _QuickReminder('Morning of task (6 AM)', 0, isMorning: true),
  ];

  @override
  void initState() {
    super.initState();
    final base = widget.currentReminder ?? widget.task.dueTime;
    selectedDate = base;
    selectedTime = TimeOfDay(hour: base.hour, minute: base.minute);
  }

  void _applyQuick(_QuickReminder opt) {
    DateTime dt;
    if (opt.isMorning) {
      dt = DateTime(widget.task.dueTime.year, widget.task.dueTime.month,
          widget.task.dueTime.day, 6, 0);
    } else {
      dt = widget.task.dueTime.add(Duration(minutes: opt.minuteOffset));
    }
    setState(() {
      selectedDate = dt;
      selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: widget.task.dueTime.add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  DateTime get finalDateTime => DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_active,
                    color: Color(0xFF1565C0), size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set Reminder',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Get notified on time',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ]),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Options',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600])),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(quickOptions.length, (i) {
                    final isSelected = selectedQuickIndex == i;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => selectedQuickIndex = i);
                        _applyQuick(quickOptions[i]);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1565C0)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1565C0)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          quickOptions[i].label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFF1565C0), size: 20),
                      const SizedBox(height: 6),
                      Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      Text('Date',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(children: [
                      const Icon(Icons.access_time_filled,
                          color: Color(0xFF1565C0), size: 20),
                      const SizedBox(height: 6),
                      Text(
                        '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      Text('Time',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.notifications_active, size: 20),
              label: Text(
                'Confirm Reminder — ${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.pop(context);
                widget.onReminderSet(finalDateTime);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper data class ─────────────────────────────────────────────
class _QuickReminder {
  final String label;
  final int minuteOffset;
  final bool isMorning;
  const _QuickReminder(this.label, this.minuteOffset, {this.isMorning = false});
}
