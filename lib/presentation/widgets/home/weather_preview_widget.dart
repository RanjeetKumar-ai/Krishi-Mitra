/// Weather Preview Widget
/// Compact weather display in header with animation
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/weather_model.dart';

class WeatherPreviewWidget extends StatefulWidget {
  final WeatherModel weather;
  final VoidCallback onTap;

  const WeatherPreviewWidget({
    super.key,
    required this.weather,
    required this.onTap,
  });

  @override
  State<WeatherPreviewWidget> createState() => _WeatherPreviewWidgetState();
}

class _WeatherPreviewWidgetState extends State<WeatherPreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Weather Icon
            AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    widget.weather.condition.toLowerCase().contains('rain')
                        ? (2 * _iconController.value)
                        : 0,
                  ),
                  child: Text(
                    widget.weather.iconCode,
                    style: const TextStyle(fontSize: 24),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),

            // Temperature
            Text(
              widget.weather.tempText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 8),

            // Separator
            Container(
              width: 1,
              height: 20,
              color: AppColors.white.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 8),

            // Rain Probability
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop,
                  color: widget.weather.rainProbability > 50
                      ? AppColors.waterBlue
                      : AppColors.white.withValues(alpha: 0.8),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.weather.rainText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 6),

            // Tap indicator
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.white.withValues(alpha: 0.7),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
