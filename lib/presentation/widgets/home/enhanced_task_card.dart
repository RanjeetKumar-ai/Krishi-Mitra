// lib/features/widgets/tasks/enhanced_task_card.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/task_model.dart';
import '../common/voice_play_button.dart';
import '../../../services/localization/tts_service.dart';

class EnhancedTaskCard extends StatefulWidget {
  final TaskModel task;
  final int number;
  final VoidCallback onTap;
  final Function(TaskModel)? onComplete;

  const EnhancedTaskCard({
    super.key,
    required this.task,
    required this.number,
    required this.onTap,
    this.onComplete,
  });

  @override
  State<EnhancedTaskCard> createState() => _EnhancedTaskCardState();
}

class _EnhancedTaskCardState extends State<EnhancedTaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _completionController;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _completionController.dispose();
    super.dispose();
  }

  void _markComplete() {
    HapticFeedback.heavyImpact();
    setState(() => _showConfetti = true);
    _completionController.forward();
    widget.onComplete?.call(widget.task);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showConfetti = false);
    });
  }

  /// Builds language-aware speak text for this task card
  String get _speakText {
    final t = widget.task;
    final dueStr =
        '${t.dueTime.hour}:${t.dueTime.minute.toString().padLeft(2, '0')}';

    if (TtsService.instance.isHindi) {
      return '${t.title}. '
          'फसल: ${t.cropName}. '
          '${t.isOverdue ? 'यह कार्य समय सीमा पार कर चुका है।' : 'समय सीमा $dueStr बजे।'}'
          '${t.quantity != null ? ' आवश्यक मात्रा: ${t.quantity}.' : ''}';
    }
    return '${t.title}. '
        'Crop: ${t.cropName}. '
        '${t.isOverdue ? 'This task is overdue.' : 'Due at $dueStr.'}'
        '${t.quantity != null ? ' Required quantity: ${t.quantity}.' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.status == TaskStatus.completed;
    final isOverdue = widget.task.isOverdue && !isCompleted;
    final isSnoozed = widget.task.status == TaskStatus.snoozed;
    final hoursUntilDue =
        widget.task.dueTime.difference(DateTime.now()).inHours;
    final isUrgent = hoursUntilDue <= 2 && hoursUntilDue > 0;
    final isDueSoon = hoursUntilDue <= 6 && hoursUntilDue > 2;

    return AnimatedOpacity(
      opacity: isCompleted ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showQuickActions(context);
        },
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.successGreen.withValues(alpha: (0.05))
                    : AppColors.backgroundCard,
                border: Border.all(
                  color: isOverdue
                      ? AppColors.errorRed
                      : isCompleted
                          ? AppColors.successGreen
                          : AppColors.borderLight,
                  width: isOverdue ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isOverdue
                    ? [
                        BoxShadow(
                          color: AppColors.errorRed.withValues(alpha: (0.2)),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Number / Check badge
                      ScaleTransition(
                        scale: Tween(begin: 1.0, end: 1.3).animate(
                          CurvedAnimation(
                            parent: _completionController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.successGreen
                                : isOverdue
                                    ? AppColors.errorRed
                                    : AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check,
                                    color: AppColors.white, size: 28)
                                : Text(
                                    '${widget.number}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title + crop + time badges
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.task.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.local_florist,
                                    size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.task.cropName} - ${widget.task.fieldSizeText}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _buildTimeBadge(context, isOverdue),
                                if (isUrgent && !isCompleted && !isOverdue)
                                  _buildUrgencyBadge(
                                      context, 'URGENT', AppColors.errorRed),
                                if (isDueSoon && !isCompleted && !isOverdue)
                                  _buildUrgencyBadge(context, 'DUE SOON',
                                      AppColors.warningOrange),
                                if (isSnoozed)
                                  _buildUrgencyBadge(
                                      context, 'SNOOZED', AppColors.mediumGray),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // ── ACTION COLUMN ──────────────────────────────
                      Column(
                        children: [
                          // ✅ FIX: Pass task.id as speakId — each card is isolated
                          VoicePlayButton(
                            speakText: _speakText,
                            speakId: 'task_card_${widget.task.id}',
                          ),
                          const SizedBox(height: 8),
                          if (!isCompleted)
                            GestureDetector(
                              onTap: _markComplete,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.successGreen.withValues(alpha: (0.1)),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.successGreen,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(Icons.check,
                                    color: AppColors.successGreen, size: 16),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Quantity row
                  if (widget.task.quantity != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow.withValues(alpha: (0.1)),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.accentYellow.withValues(alpha: (0.3)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.scale,
                                size: 16, color: AppColors.accentYellow),
                            const SizedBox(width: 6),
                            Text(
                              widget.task.quantity!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentYellow,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Confetti overlay
            if (_showConfetti)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: RadialGradient(
                        colors: [
                          AppColors.successGreen.withValues(alpha: (0.3)),
                          Colors.transparent,
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
  }

  Widget _buildTimeBadge(BuildContext context, bool isOverdue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue
            ? AppColors.errorRed.withValues(alpha: (0.1))
            : AppColors.primaryGreen.withValues(alpha: (0.1)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning : Icons.access_time,
            size: 12,
            color: isOverdue ? AppColors.errorRed : AppColors.primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            isOverdue
                ? 'OVERDUE'
                : 'Due ${widget.task.dueTime.hour}:${widget.task.dueTime.minute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      isOverdue ? AppColors.errorRed : AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: (0.15)),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: (0.5)), width: 1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  const Icon(Icons.check_circle, color: AppColors.successGreen),
              title: const Text('Mark as Completed'),
              onTap: () {
                Navigator.pop(context);
                _markComplete();
              },
            ),
            ListTile(
              leading: const Icon(Icons.snooze, color: AppColors.warningOrange),
              title: const Text('Snooze for 24 Hours'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info, color: AppColors.accentBlue),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                widget.onTap();
              },
            ),
          ],
        ),
      ),
    );
  }
}
