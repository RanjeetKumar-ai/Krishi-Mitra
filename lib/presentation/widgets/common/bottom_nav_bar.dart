/// Bottom Navigation Bar Widget
/// Fixed to show only ONE indicator (oval style)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.grass,
                label: 'Crops',
                index: 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.camera_alt,
                label: 'Scanner',
                index: 2,
                isCenter: true,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.cloud,
                label: 'Weather',
                index: 3,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person,
                label: 'Profile',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    bool isCenter = false,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(index);
      },
      child: Container(
        width: 72,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with background (ONLY indicator)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 20 : 12,
                vertical: isSelected ? 10 : 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isCenter
                        ? AppColors.primaryGreen
                        : AppColors.primaryGreen.withValues(alpha: 0.15))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? (isCenter ? AppColors.white : AppColors.primaryGreen)
                    : AppColors.textSecondary,
                size: isCenter ? 28 : 24,
              ),
            ),

            const SizedBox(height: 4),

            // Label
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
