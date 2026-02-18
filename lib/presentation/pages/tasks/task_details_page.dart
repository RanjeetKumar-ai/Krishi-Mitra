/// Task Details Screen
/// Shows complete task information with step-by-step instructions
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/task_model.dart';

class TaskDetailsPage extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TaskModel _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              HapticFeedback.mediumImpact();
              // Implement TTS for instructions
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: _task.isOverdue
                    ? const LinearGradient(
                        colors: [AppColors.errorRed, AppColors.warningOrange],
                      )
                    : AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _task.statusText.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    _task.title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Crop Info
                  Row(
                    children: [
                      const Icon(Icons.local_florist,
                          color: AppColors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_task.cropName} - ${_task.fieldSizeText}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Due Time
                  Row(
                    children: [
                      Icon(
                        _task.isOverdue ? Icons.warning : Icons.access_time,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _task.isOverdue
                            ? 'OVERDUE'
                            : 'Due by ${_task.dueTime.hour}:${_task.dueTime.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quantity Info (if available)
            if (_task.quantity != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.accentYellow),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.scale,
                          color: AppColors.accentYellow, size: 24),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Required Quantity',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _task.quantity!,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentYellow,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Instructions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step-by-Step Instructions',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Instruction Steps
                  ...List.generate(_task.instructions.length, (index) {
                    return _buildInstructionStep(
                      context,
                      index + 1,
                      _task.instructions[index],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Video Link (if available)
            if (_task.videoUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.accentBlue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_outline,
                          color: AppColors.accentBlue, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Video Guide Available',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to watch tutorial',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Mark as Completed
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.check_circle, size: 24),
                      label: const Text(
                        'Mark as Completed',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _markAsCompleted(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Snooze
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.accentOrange),
                      ),
                      icon: const Icon(Icons.snooze,
                          color: AppColors.accentOrange),
                      label: const Text(
                        'Snooze for 24 Hours',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentOrange,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _snoozeTask(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Report Issue
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.errorRed),
                      ),
                      icon: const Icon(Icons.report_problem,
                          color: AppColors.errorRed),
                      label: const Text(
                        'Report Issue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.errorRed,
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
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
      BuildContext context, int stepNumber, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Instruction Text
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                instruction,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsCompleted(BuildContext context) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _task = _task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );
    });

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Task marked as completed!'),
        backgroundColor: AppColors.successGreen,
        duration: Duration(seconds: 2),
      ),
    );

    // Store navigator reference before async gap
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        navigator.pop();
      }
    });
  }

  void _snoozeTask(BuildContext context) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _task = _task.copyWith(status: TaskStatus.snoozed);
    });

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Task snoozed for 24 hours'),
        backgroundColor: AppColors.accentOrange,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        navigator.pop();
      }
    });
  }

  void _reportIssue(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report Issue'),
        content: const Text('What problem did you encounter with this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();

              // Safe usage with stored reference
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Issue reported. We\'ll look into it.'),
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
}
