/// Enhanced Alert Card Widget
/// Improved UX with badges, preview, and swipe-to-acknowledge
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/alert_model.dart';

class EnhancedAlertCard extends StatefulWidget {
  final AlertModel alert;
  final VoidCallback onTap;
  final Function(AlertModel)? onAcknowledge;

  const EnhancedAlertCard({
    super.key,
    required this.alert,
    required this.onTap,
    this.onAcknowledge,
  });

  @override
  State<EnhancedAlertCard> createState() => _EnhancedAlertCardState();
}

class _EnhancedAlertCardState extends State<EnhancedAlertCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(widget.alert.severity);
    final isCritical = widget.alert.severity == AlertSeverity.critical ||
        widget.alert.severity == AlertSeverity.high;

    return Dismissible(
      key: Key(widget.alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.successGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppColors.white, size: 32),
            SizedBox(height: 4),
            Text(
              'Acknowledge',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        if (widget.onAcknowledge != null) {
          widget.onAcknowledge!(widget.alert);
        }
        return true;
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (isCritical) {
            HapticFeedback.heavyImpact();
          }
          widget.onTap();
        },
        onLongPress: () {
          setState(() => _isExpanded = !_isExpanded);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: severityColor.withValues(alpha: 0.08),
            border: Border.all(
              color: severityColor.withValues(alpha: isCritical ? 0.6 : 0.3),
              width: isCritical ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isCritical
                ? [
                    BoxShadow(
                      color: severityColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.alert.typeIcon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title & Badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Severity Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: severityColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.alert.severityText,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Title
                        Text(
                          widget.alert.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Description (always visible)
              Text(
                widget.alert.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                    ),
                maxLines: _isExpanded ? null : 2,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
              ),

              // Expanded Content
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      ...widget.alert.doList.take(2).map((tip) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: severityColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: severityColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onTap();
                  },
                  child: Text(
                    'View Full Details',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),

              // Swipe hint
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swipe_left,
                    size: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe left to acknowledge',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return AppColors.infoBlue;
      case AlertSeverity.medium:
        return AppColors.warningOrange;
      case AlertSeverity.high:
        return AppColors.errorRed;
      case AlertSeverity.critical:
        return AppColors.diseaseRed;
    }
  }
}
