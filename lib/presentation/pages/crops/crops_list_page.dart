/// Crops List Screen
/// Shows all crops managed by the farmer
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/crop_model.dart';
import '../../../data/dummy_data.dart';
import 'crop_detail_page.dart';

class CropsListPage extends StatelessWidget {
  const CropsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final crops = DummyData.crops;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Crops'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Show filter options
            },
          ),
        ],
      ),
      body: crops.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: crops.length,
              itemBuilder: (context, index) {
                return _buildCropCard(context, crops[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          // Navigate to Add Crop flow
        },
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('Add Crop'),
      ),
    );
  }

  Widget _buildCropCard(BuildContext context, CropModel crop) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CropDetailPage(crop: crop),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
          children: [
            // Header with crop icon and name
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: _getHealthGradient(crop.healthStatus),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Crop Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(crop.iconEmoji,
                          style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Crop Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            crop.phaseText,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Health Badge
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getHealthIcon(crop.healthStatus),
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Progress and details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${crop.progressPercentage}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: crop.progressPercentage / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailItem(
                          context, Icons.landscape, '${crop.fieldSize} acres'),
                      _buildDetailItem(context, Icons.layers, crop.soilType),
                      _buildDetailItem(
                        context,
                        Icons.calendar_today,
                        '${crop.sowDate.day} Jan',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_florist_outlined,
              size: 80, color: AppColors.mediumGray),
          const SizedBox(height: 16),
          Text(
            'No Crops Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first crop to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getHealthGradient(CropHealthStatus status) {
    switch (status) {
      case CropHealthStatus.good:
        return AppColors.primaryGradient;
      case CropHealthStatus.warning:
        return const LinearGradient(
          colors: [AppColors.warningOrange, AppColors.accentOrange],
        );
      case CropHealthStatus.risk:
        return const LinearGradient(
          colors: [AppColors.diseaseRed, AppColors.errorRed],
        );
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
}
