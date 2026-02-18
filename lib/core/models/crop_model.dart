/// Crop Data Model
/// Represents crops in farmer's field
library;

enum CropPhase {
  seedling,
  vegetative,
  flowering,
  fruiting,
  maturation,
  harvest
}

enum CropHealthStatus { good, warning, risk }

class CropModel {
  final String id;
  final String name;
  final String iconEmoji;
  final CropPhase currentPhase;
  final int progressPercentage;
  final DateTime sowDate;
  final double fieldSize;
  final String soilType;
  final CropHealthStatus healthStatus;
  final DateTime? expectedHarvestDate;
  final List<String> recentActions;
  final List<String> upcomingTasks;
  final CropPhase? nextPhase;
  final int? daysToNextPhase;

  CropModel({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.currentPhase,
    required this.progressPercentage,
    required this.sowDate,
    required this.fieldSize,
    required this.soilType,
    required this.healthStatus,
    this.expectedHarvestDate,
    this.recentActions = const [],
    this.upcomingTasks = const [],
    this.nextPhase,
    this.daysToNextPhase,
  });

  CropModel copyWith({
    String? id,
    String? name,
    String? iconEmoji,
    CropPhase? currentPhase,
    int? progressPercentage,
    DateTime? sowDate,
    double? fieldSize,
    String? soilType,
    CropHealthStatus? healthStatus,
    DateTime? expectedHarvestDate,
    List<String>? recentActions,
    List<String>? upcomingTasks,
    CropPhase? nextPhase,
    int? daysToNextPhase,
  }) {
    return CropModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      currentPhase: currentPhase ?? this.currentPhase,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      sowDate: sowDate ?? this.sowDate,
      fieldSize: fieldSize ?? this.fieldSize,
      soilType: soilType ?? this.soilType,
      healthStatus: healthStatus ?? this.healthStatus,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      recentActions: recentActions ?? this.recentActions,
      upcomingTasks: upcomingTasks ?? this.upcomingTasks,
      nextPhase: nextPhase ?? this.nextPhase,
      daysToNextPhase: daysToNextPhase ?? this.daysToNextPhase,
    );
  }

  String get phaseText {
    switch (currentPhase) {
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
        return 'Ready to Harvest';
    }
  }

  String get healthStatusText {
    switch (healthStatus) {
      case CropHealthStatus.good:
        return 'Good';
      case CropHealthStatus.warning:
        return 'Warning';
      case CropHealthStatus.risk:
        return 'At Risk';
    }
  }
}
