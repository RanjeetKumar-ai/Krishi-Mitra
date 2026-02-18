/// Enhanced Crop Card Widget
/// Improved visibility, progress bars, and quick actions
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/crop_model.dart';

class EnhancedCropCard extends StatefulWidget {
  final CropModel crop;
  final VoidCallback onTap;

  const EnhancedCropCard({
    super.key,
    required this.crop,
    required this.onTap,
  });

  @override
  State<EnhancedCropCard> createState() => _EnhancedCropCardState();
}

class _EnhancedCropCardState extends State<EnhancedCropCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.crop.progressPercentage / 100,
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showQuickActions(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Image/Icon Section
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: _getHealthGradient(widget.crop.healthStatus),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  // Crop Emoji/Icon
                  Center(
                    child: Text(
                      widget.crop.iconEmoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),

                  // Health Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getHealthIcon(widget.crop.healthStatus),
                            size: 14,
                            color: _getHealthColor(widget.crop.healthStatus),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.crop.healthStatusText,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _getHealthColor(widget.crop.healthStatus),
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop Name
                  Text(
                    widget.crop.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),

                  // Current Phase
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      widget.crop.phaseText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Growth Progress',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Text(
                            '${(_progressAnimation.value * 100).toInt()}%',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
                                    ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Enhanced Progress Bar (thicker for sunlight visibility)
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 10, // Increased from 6 to 10
                          child: LinearProgressIndicator(
                            value: _progressAnimation.value,
                            backgroundColor:
                                AppColors.primaryGreen.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getHealthColor(widget.crop.healthStatus),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Next Action Reminder
                  if (widget.crop.upcomingTasks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accentBlue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notification_important,
                            size: 16,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Next: ${widget.crop.upcomingTasks.first}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.accentBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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

  LinearGradient _getHealthGradient(CropHealthStatus status) {
    switch (status) {
      case CropHealthStatus.good:
        return const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.healthyGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CropHealthStatus.warning:
        return const LinearGradient(
          colors: [AppColors.warningOrange, AppColors.accentOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CropHealthStatus.risk:
        return const LinearGradient(
          colors: [AppColors.diseaseRed, AppColors.errorRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getHealthColor(CropHealthStatus status) {
    switch (status) {
      case CropHealthStatus.good:
        return AppColors.successGreen;
      case CropHealthStatus.warning:
        return AppColors.warningOrange;
      case CropHealthStatus.risk:
        return AppColors.diseaseRed;
    }
  }

  IconData _getHealthIcon(CropHealthStatus status) {
    switch (status) {
      case CropHealthStatus.good:
        return Icons.check_circle;
      case CropHealthStatus.warning:
        return Icons.warning;
      case CropHealthStatus.risk:
        return Icons.error;
    }
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
              '${widget.crop.name} - Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primaryGreen),
              title: const Text('Edit Crop Details'),
              onTap: () {
                Navigator.pop(context);
                // Handle edit
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add, color: AppColors.accentBlue),
              title: const Text('Add Note'),
              onTap: () {
                Navigator.pop(context);
                // Handle add note
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt, color: AppColors.accentOrange),
              title: const Text('Upload Photo'),
              onTap: () {
                Navigator.pop(context);
                // Handle photo upload
              },
            ),
          ],
        ),
      ),
    );
  }
}
