/// My Crops Screen - REDESIGNED
/// Farmer-friendly list with smooth animations and India-specific theming
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/crop_model.dart';
import '../../../data/dummy_data.dart';
import 'crop_detail_page.dart';

class CropsListPage extends StatefulWidget {
  const CropsListPage({super.key});

  @override
  State<CropsListPage> createState() => _CropsListPageState();
}

class _CropsListPageState extends State<CropsListPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  bool _showOnlyActive = true;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCrops = DummyData.crops;
    final crops = _showOnlyActive
        ? allCrops.where((c) => c.progressPercentage < 100).toList()
        : allCrops;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'My Crops',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          // Simple active/all toggle – farmer friendly
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _showOnlyActive = !_showOnlyActive);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: (0.2)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: (0.6)),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _showOnlyActive
                          ? Icons.grass
                          : Icons.inventory_2_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showOnlyActive ? 'Active' : 'All',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: crops.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                // Small header strip with “Khet Overview”
                _buildOverviewStrip(crops),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: crops.length,
                    itemBuilder: (context, index) {
                      final animation = CurvedAnimation(
                        parent: _introController,
                        curve: Interval(
                          (index / (crops.length + 1)).clamp(0.0, 1.0),
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: _buildCropCard(context, crops[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ==================== SMALL OVERVIEW STRIP ====================
  Widget _buildOverviewStrip(List<CropModel> crops) {
    final totalArea = crops.fold<double>(
        0, (sum, c) => sum + c.fieldSize); // fieldSize non-null
    final avgProgress = crops.isEmpty
        ? 0
        : (crops.fold<int>(0, (sum, c) => sum + c.progressPercentage) /
                crops.length)
            .round();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.agriculture, color: Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Khet overview • ${totalArea.toStringAsFixed(1)} acres • Avg growth $avgProgress%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CROP CARD ====================
  Widget _buildCropCard(BuildContext context, CropModel crop) {
    final healthGradient = _getHealthGradient(crop.healthStatus);
    final healthIcon = _getHealthIcon(crop.healthStatus);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => CropDetailPage(crop: crop),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(
              opacity: anim,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: (0.08)),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: healthGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Emoji avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: (0.25)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: (0.6)),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        crop.iconEmoji,
                        style: const TextStyle(fontSize: 34),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: (0.25)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                crop.phaseText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• ${crop.healthStatusText}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: (0.9)),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: (0.25)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      healthIcon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // BODY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${crop.progressPercentage}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: crop.progressPercentage / 100,
                      minHeight: 10,
                      backgroundColor: AppColors.primaryGreen.withValues(alpha: (0.12)),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info row with icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailChip(
                        icon: Icons.landscape,
                        label: '${crop.fieldSize.toStringAsFixed(1)} acres',
                      ),
                      _buildDetailChip(
                        icon: Icons.layers,
                        label: crop.soilType,
                      ),
                      _buildDetailChip(
                        icon: Icons.calendar_today,
                        label:
                            '${crop.sowDate.day} ${_monthShort(crop.sowDate)}',
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // “Next step” hint
                  if (crop.nextPhase != null)
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_circle_right_outlined,
                          size: 18,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Next: ${_phaseText(crop.nextPhase!)} in ${crop.daysToNextPhase} days',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

  // ==================== DETAIL CHIP ====================
  Widget _buildDetailChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FAB ====================
  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        // TODO: Navigate to add crop flow
      },
      backgroundColor: AppColors.primaryGreen,
      elevation: 4,
      icon: const Icon(Icons.add),
      label: const Text(
        'Add Crop',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.agriculture, size: 80, color: Color(0xFFB0BEC5)),
            const SizedBox(height: 16),
            const Text(
              'No crops added yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap “Add Crop” to start tracking your kheti in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPERS ====================
  LinearGradient _getHealthGradient(CropHealthStatus status) {
    switch (status) {
      case CropHealthStatus.good:
        return const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CropHealthStatus.warning:
        return const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CropHealthStatus.risk:
        return const LinearGradient(
          colors: [Color(0xFFEF5350), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getHealthIcon(CropHealthStatus status) {
    switch (status) {
      case CropHealthStatus.good:
        return Icons.check_circle;
      case CropHealthStatus.warning:
        return Icons.warning_amber_rounded;
      case CropHealthStatus.risk:
        return Icons.error;
    }
  }

  String _monthShort(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[date.month - 1];
  }

  String _phaseText(CropPhase phase) {
    switch (phase) {
      case CropPhase.seedling:
        return 'Seedling';
      case CropPhase.vegetative:
        return 'Vegetative';
      case CropPhase.flowering:
        return 'Flowering';
      case CropPhase.fruiting:
        return 'Fruiting';
      case CropPhase.maturation:
        return 'Maturation';
      case CropPhase.harvest:
        return 'Harvest';
    }
  }
}
