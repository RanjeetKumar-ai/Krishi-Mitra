// lib/features/pages/tasks/task_details_page.dart
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/task_model.dart';
import '../../../services/localization/tts_service.dart';

// ═══════════════════════════════════════════════════════════════════
//  TaskDetailsPage
// ═══════════════════════════════════════════════════════════════════

class TaskDetailsPage extends StatefulWidget {
  final TaskModel task;
  const TaskDetailsPage({super.key, required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage>
    with TickerProviderStateMixin {
  late TaskModel _task;
  static const String _speakId = 'task_detail_page';

  // Reminder state
  DateTime? _reminderTime;
  bool _reminderSet = false;

  // Step completion tracking
  late List<bool> _stepsDone;

  // Animations
  late final AnimationController _headerPulseController;
  late final AnimationController _completionController;
  bool _showSuccessOverlay = false;

  // Countdown timer display
  Timer? _countdownTimer;
  Duration _timeUntilDue = Duration.zero;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _stepsDone = List.filled(_task.instructions.length, false);

    _headerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _startCountdown();
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _headerPulseController.dispose();
    _completionController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timeUntilDue = _task.dueTime.difference(DateTime.now());
    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _timeUntilDue = _task.dueTime.difference(DateTime.now());
        });
      }
    });
  }

  // ─── Progress ──────────────────────────────────────────────────

  int get _completedSteps => _stepsDone.where((s) => s).length;
  double get _progress =>
      _stepsDone.isEmpty ? 0 : _completedSteps / _stepsDone.length;

  // ─── TTS speak text (bilingual) ────────────────────────────────

  String get _speakText {
    final dueStr =
        '${_task.dueTime.hour}:${_task.dueTime.minute.toString().padLeft(2, '0')}';
    final steps = _task.instructions
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('. ');

    if (TtsService.instance.isHindi) {
      return 'कार्य: ${_task.title}. '
          'फसल: ${_task.cropName}, ${_task.fieldSizeText}. '
          '${_task.isOverdue ? 'यह कार्य समय सीमा पार कर चुका है।' : 'समय सीमा $dueStr बजे।'} '
          '${_task.quantity != null ? 'आवश्यक मात्रा: ${_task.quantity}. ' : ''}'
          'निर्देश: $steps';
    }
    return 'Task: ${_task.title}. '
        'Crop: ${_task.cropName}, ${_task.fieldSizeText}. '
        '${_task.isOverdue ? 'This task is overdue.' : 'Due at $dueStr.'} '
        '${_task.quantity != null ? 'Required quantity: ${_task.quantity}. ' : ''}'
        'Instructions: $steps';
  }

  // ─── Countdown label ───────────────────────────────────────────

  String get _countdownLabel {
    if (_task.isOverdue) return 'Overdue';
    if (_timeUntilDue.isNegative) return 'Overdue';
    final h = _timeUntilDue.inHours;
    final m = _timeUntilDue.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m left';
    if (m > 0) return '${m}m left';
    return 'Due now';
  }

  Color get _headerTopColor {
    if (_task.isOverdue) return const Color(0xFFD32F2F);
    if (_timeUntilDue.inHours <= 2) return const Color(0xFFE64A19);
    return const Color(0xFF2E7D32);
  }

  Color get _headerBottomColor {
    if (_task.isOverdue) return const Color(0xFFFF6B35);
    if (_timeUntilDue.inHours <= 2) return const Color(0xFFFFA726);
    return const Color(0xFF66BB6A);
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isCompleted = _task.status == TaskStatus.completed;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F0),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero Header SliverAppBar ──────────────────────
              _buildSliverHeader(context, isCompleted),

              // ── Body content ─────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Quick info strip
                    _buildInfoStrip(context),
                    const SizedBox(height: 16),

                    // ── REMINDER CARD ──────────────────────────
                    _buildReminderCard(context),
                    const SizedBox(height: 16),

                    // Quantity
                    if (_task.quantity != null) ...[
                      _buildQuantityCard(context),
                      const SizedBox(height: 16),
                    ],

                    // Progress bar
                    if (!isCompleted) ...[
                      _buildProgressCard(context),
                      const SizedBox(height: 16),
                    ],

                    // Step-by-step instructions
                    _buildInstructionsSection(context, isCompleted),
                    const SizedBox(height: 16),

                    // Video guide
                    if (_task.videoUrl != null) ...[
                      _buildVideoCard(context),
                      const SizedBox(height: 16),
                    ],

                    // Action buttons
                    _buildActionButtons(context, isCompleted),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),

          // Success overlay
          if (_showSuccessOverlay) _buildSuccessOverlay(context),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SLIVER HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSliverHeader(BuildContext context, bool isCompleted) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: _headerTopColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: (0.25)),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // TTS button
        _buildVoiceButton(),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: AnimatedBuilder(
          animation: _headerPulseController,
          builder: (_, __) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_headerTopColor, _headerBottomColor],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Status + countdown row
                  Row(
                    children: [
                      _buildStatusBadge(),
                      const Spacer(),
                      if (!isCompleted) _buildCountdownBadge(),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Task title
                  Text(
                    _task.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Crop + field row
                  Row(
                    children: [
                      const Icon(Icons.local_florist,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${_task.cropName}  •  ${_task.fieldSizeText}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      // Pinned collapsed title
      title: Text(
        _task.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildStatusBadge() {
    Color bg;
    String label;

    switch (_task.status) {
      case TaskStatus.completed:
        bg = Colors.green.shade400;
        label = '✓ COMPLETED';
        break;
      case TaskStatus.snoozed:
        bg = Colors.orange.shade400;
        label = '⏱ SNOOZED';
        break;
      default:
        bg = _task.isOverdue
            ? Colors.red.shade400
            : Colors.white.withValues(alpha: (0.3));
        label = _task.isOverdue ? '⚠ OVERDUE' : '🌾 PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCountdownBadge() {
    final isUrgent = _task.isOverdue || _timeUntilDue.inHours <= 2;
    return AnimatedBuilder(
      animation: _headerPulseController,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isUrgent
              ? Colors.white.withValues(
                  alpha: (0.15 + _headerPulseController.value * 0.15))
              : Colors.white.withValues(alpha: (0.2)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: (0.5)), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUrgent ? Icons.alarm : Icons.access_time,
              color: Colors.white,
              size: 13,
            ),
            const SizedBox(width: 5),
            Text(
              _countdownLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Voice button ──────────────────────────────────────────────

  Widget _buildVoiceButton() {
    return ValueListenableBuilder<String?>(
      valueListenable: TtsService.instance.currentSpeakId,
      builder: (context, activeId, _) {
        final isSpeaking = activeId == _speakId;
        return GestureDetector(
          onTap: () async {
            HapticFeedback.mediumImpact();
            if (isSpeaking) {
              await TtsService.instance.stop();
            } else {
              await TtsService.instance.speak(
                _speakText,
                speakId: _speakId,
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isSpeaking
                  ? Colors.white.withValues(alpha: (0.35))
                  : Colors.white.withValues(alpha: (0.2)),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: (isSpeaking ? 0.9 : 0.4)),
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

  // ═══════════════════════════════════════════════════════════════
  //  INFO STRIP
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInfoStrip(BuildContext context) {
    final dueStr =
        '${_task.dueTime.hour}:${_task.dueTime.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${_task.dueTime.day}/${_task.dueTime.month}/${_task.dueTime.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoChip(
              icon: Icons.calendar_today,
              label: 'Date',
              value: dateStr,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildInfoChip(
              icon: Icons.access_time_filled,
              label: 'Due Time',
              value: dueStr,
              color: const Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildInfoChip(
              icon: Icons.format_list_numbered,
              label: 'Steps',
              value: '${_task.instructions.length}',
              color: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
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
        border: Border.all(color: color.withValues(alpha: (0.2))),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: (0.06)),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  REMINDER CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildReminderCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _reminderSet
              ? const Color(0xFF1565C0).withValues(alpha: (0.07))
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _reminderSet
                ? const Color(0xFF1565C0).withValues(alpha: (0.5))
                : Colors.grey.shade200,
            width: _reminderSet ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: (0.04)),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bell icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _reminderSet
                    ? const Color(0xFF1565C0).withValues(alpha: (0.12))
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _reminderSet
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                color:
                    _reminderSet ? const Color(0xFF1565C0) : Colors.grey[500],
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _reminderSet ? 'Reminder Set' : 'Set Reminder',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _reminderSet
                          ? const Color(0xFF1565C0)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _reminderSet && _reminderTime != null
                        ? '${_reminderTime!.day}/${_reminderTime!.month}  at  '
                            '${_reminderTime!.hour}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                        : 'Tap to get notified before this task',
                    style: TextStyle(
                      fontSize: 12,
                      color: _reminderSet
                          ? const Color(0xFF1565C0)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            if (_reminderSet)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit
                  GestureDetector(
                    onTap: () => _showReminderPicker(context),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withValues(alpha: (0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit,
                          color: Color(0xFF1565C0), size: 16),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Cancel
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _reminderSet = false;
                        _reminderTime = null;
                      });
                      _showSnack(context, 'Reminder cancelled', Colors.grey);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withValues(alpha: (0.08)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close,
                          color: AppColors.errorRed, size: 16),
                    ),
                  ),
                ],
              )
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
                  child: const Text(
                    'Set',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  QUANTITY CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildQuantityCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.accentYellow.withValues(alpha: (0.5)),
              width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentYellow.withValues(alpha: (0.08)),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withValues(alpha: (0.12)),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.scale,
                  color: AppColors.accentYellow, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Required Quantity',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _task.quantity!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accentYellow,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withValues(alpha: (0.1)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.accentYellow.withValues(alpha: (0.3))),
              ),
              child: const Text(
                '📦 Materials Ready?',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentYellow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PROGRESS CARD
  // ═══════════════════════════════════════════════════════════════

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Task Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$_completedSteps / ${_stepsDone.length} steps',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _progress == 1.0
                      ? AppColors.successGreen
                      : AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _progress == 0
                  ? 'Tap steps below to mark them done'
                  : _progress == 1.0
                      ? '🎉 All steps complete! Tap "Mark as Completed"'
                      : '${(_progress * 100).toInt()}% done — keep going!',
              style: TextStyle(
                fontSize: 11,
                color: _progress == 1.0
                    ? AppColors.successGreen
                    : Colors.grey[500],
                fontWeight:
                    _progress == 1.0 ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  INSTRUCTIONS SECTION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInstructionsSection(BuildContext context, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: (0.12)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.format_list_numbered,
                    color: AppColors.primaryGreen, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Step-by-Step Instructions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (!isCompleted)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      final allDone = _stepsDone.every((s) => s);
                      _stepsDone = List.filled(_stepsDone.length, !allDone);
                    });
                  },
                  child: Text(
                    _stepsDone.every((s) => s) ? 'Reset All' : 'Mark All',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Step cards
          ...List.generate(_task.instructions.length, (index) {
            return _buildInstructionStep(
                context, index, _task.instructions[index], isCompleted);
          }),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(
    BuildContext context,
    int index,
    String instruction,
    bool taskCompleted,
  ) {
    final isDone = taskCompleted || _stepsDone[index];
    final stepNum = index + 1;

    return GestureDetector(
      onTap: taskCompleted
          ? null
          : () {
              HapticFeedback.selectionClick();
              setState(() => _stepsDone[index] = !_stepsDone[index]);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDone
              ? AppColors.successGreen.withValues(alpha: (0.06))
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone
                ? AppColors.successGreen.withValues(alpha: (0.5))
                : Colors.grey.shade200,
            width: isDone ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: (0.03)),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step number circle
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
                    : Text(
                        '$stepNum',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Instruction text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step $stepNum',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDone ? AppColors.successGreen : Colors.grey[400],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    instruction,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDone ? Colors.grey[500] : Colors.black87,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.grey[400],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Tap hint
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

  // ═══════════════════════════════════════════════════════════════
  //  VIDEO CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildVideoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.accentBlue.withValues(alpha: (0.4)), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withValues(alpha: (0.06)),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: (0.12)),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_circle_filled,
                  color: AppColors.accentBlue, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎬 Video Guide Available',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Watch step-by-step tutorial',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.accentBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Watch',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  ACTION BUTTONS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildActionButtons(BuildContext context, bool isCompleted) {
    if (isCompleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: (0.08)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.successGreen.withValues(alpha: (0.4)),
                width: 1.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.successGreen, size: 28),
              SizedBox(width: 10),
              Text(
                'Task Completed! 🎉',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Mark as Completed
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
              label: const Text(
                'Mark as Completed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _markAsCompleted(context);
              },
            ),
          ),
          const SizedBox(height: 10),

          // Bottom row: Snooze + Set Reminder + Report
          Row(
            children: [
              // Snooze
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.accentOrange),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.snooze,
                      color: AppColors.accentOrange, size: 18),
                  label: const Text(
                    'Snooze',
                    style: TextStyle(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showSnoozeOptions(context);
                  },
                ),
              ),
              const SizedBox(width: 10),

              // Report Issue
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.errorRed),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.report_problem,
                      color: AppColors.errorRed, size: 18),
                  label: const Text(
                    'Report',
                    style: TextStyle(
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _reportIssue(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SUCCESS OVERLAY
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSuccessOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: (0.6)),
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
                const Text(
                  'Task Done!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.successGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  TtsService.instance.isHindi
                      ? 'बहुत अच्छे! आपने यह काम पूरा कर लिया।'
                      : 'Great work, farmer! Keep it up.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  REMINDER PICKER
  // ═══════════════════════════════════════════════════════════════

  void _showReminderPicker(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ReminderPickerSheet(
        task: _task,
        currentReminder: _reminderTime,
        onReminderSet: (dt) {
          setState(() {
            _reminderTime = dt;
            _reminderSet = true;
          });
          _showSnack(
            context,
            TtsService.instance.isHindi
                ? '🔔 अनुस्मारक सेट हो गया: ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}'
                : '🔔 Reminder set for ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}',
            const Color(0xFF1565C0),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SNOOZE OPTIONS
  // ═══════════════════════════════════════════════════════════════

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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.snooze, color: AppColors.accentOrange),
                  SizedBox(width: 10),
                  Text(
                    'Snooze Task',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            ...[
              ('30 minutes', 30),
              ('1 Hour', 60),
              ('2 Hours', 120),
              ('Tomorrow Morning (6 AM)', -1),
            ].map((option) {
              return ListTile(
                leading: const Icon(Icons.access_time,
                    color: AppColors.accentOrange),
                title: Text(option.$1,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.mediumImpact();
                  final snoozeUntil = option.$2 == -1
                      ? DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day + 1,
                          6,
                          0,
                        )
                      : DateTime.now().add(Duration(minutes: option.$2));
                  setState(() {
                    _task = _task.copyWith(
                      status: TaskStatus.snoozed,
                      dueTime: snoozeUntil,
                    );
                    _reminderSet = false;
                    _reminderTime = null;
                  });
                  _startCountdown();
                  _showSnack(
                    context,
                    'Snoozed until ${snoozeUntil.hour}:${snoozeUntil.minute.toString().padLeft(2, '0')}',
                    AppColors.accentOrange,
                  );
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  MARK COMPLETED
  // ═══════════════════════════════════════════════════════════════
// ✅ AFTER — navigator captured before async, mounted-guarded
  void _markAsCompleted(BuildContext context) {
    // Capture navigator BEFORE any async gap
    final navigator = Navigator.of(context);

    TtsService.instance.stop();
    setState(() {
      _task = _task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );
      _stepsDone = List.filled(_stepsDone.length, true);
      _showSuccessOverlay = true;
    });

    // Fire-and-forget — do NOT await here, prevents async gap on context
    TtsService.instance.speak(
      TtsService.instance.isHindi
          ? 'बधाई हो! आपने यह कार्य पूरा कर लिया।'
          : 'Congratulations! Task marked as completed.',
      speakId: _speakId,
    );

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() => _showSuccessOverlay = false);
        navigator.pop(); // ✅ captured ref, no context across async
      }
    });
  }
  //  REPORT ISSUE
  // ═══════════════════════════════════════════════════════════════

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
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text("Issue reported. We'll look into it."),
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // ─── Snack helper ──────────────────────────────────────────────

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Reminder Picker Sheet
// ═══════════════════════════════════════════════════════════════════

class _ReminderPickerSheet extends StatefulWidget {
  final TaskModel task;
  final DateTime? currentReminder;
  final ValueChanged<DateTime> onReminderSet;

  const _ReminderPickerSheet({
    required this.task,
    required this.currentReminder,
    required this.onReminderSet,
  });

  @override
  State<_ReminderPickerSheet> createState() => _ReminderPickerSheetState();
}

class _ReminderPickerSheetState extends State<_ReminderPickerSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _selectedQuickIndex = -1;

  final List<_QuickReminder> _quickOptions = [
    _QuickReminder('30 min before', -30),
    _QuickReminder('1 hour before', -60),
    _QuickReminder('2 hours before', -120),
    _QuickReminder('1 day before', -1440),
    _QuickReminder('Morning of task\n(6:00 AM)', 0, isMorning: true),
  ];

  @override
  void initState() {
    super.initState();
    final base = widget.currentReminder ?? widget.task.dueTime;
    _selectedDate = base;
    _selectedTime = TimeOfDay(hour: base.hour, minute: base.minute);
  }

  void _applyQuick(_QuickReminder opt) {
    DateTime dt;
    if (opt.isMorning) {
      dt = DateTime(
        widget.task.dueTime.year,
        widget.task.dueTime.month,
        widget.task.dueTime.day,
        6,
        0,
      );
    } else {
      dt = widget.task.dueTime.add(Duration(minutes: opt.minuteOffset));
    }
    setState(() {
      _selectedDate = dt;
      _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: widget.task.dueTime.add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  DateTime get _finalDateTime => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
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
            color: Colors.black.withValues(alpha: (0.12)),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: (0.1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_active,
                      color: Color(0xFF1565C0), size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set Reminder',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'याद दिलाएं / Get notified on time',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Quick options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Options',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_quickOptions.length, (i) {
                    final isSelected = _selectedQuickIndex == i;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedQuickIndex = i);
                        _applyQuick(_quickOptions[i]);
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
                          _quickOptions[i].label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Manual date + time pickers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Date picker
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
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Color(0xFF1565C0), size: 20),
                          const SizedBox(height: 6),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Date',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Time picker
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
                      child: Column(
                        children: [
                          const Icon(Icons.access_time_filled,
                              color: Color(0xFF1565C0), size: 20),
                          const SizedBox(height: 6),
                          Text(
                            '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Time',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Confirm button
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
                'Confirm Reminder — ${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.pop(context);
                widget.onReminderSet(_finalDateTime);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper data classes ───────────────────────────────────────────

class _QuickReminder {
  final String label;
  final int minuteOffset; // negative = before due, 0 = morning
  final bool isMorning;

  const _QuickReminder(this.label, this.minuteOffset, {this.isMorning = false});
}
