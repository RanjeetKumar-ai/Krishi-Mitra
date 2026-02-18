/// App State - Global app state management
library;

import 'package:equatable/equatable.dart';
import '../../../core/models/crop_model.dart';
import '../../../core/models/task_model.dart';
import '../../../core/models/alert_model.dart';

class AppState extends Equatable {
  final String userLanguage;
  final bool isOffline;
  final CropModel? selectedCrop;
  final TaskModel? selectedTask;
  final AlertModel? selectedAlert;
  final int bottomNavIndex;

  const AppState({
    this.userLanguage = 'en',
    this.isOffline = false,
    this.selectedCrop,
    this.selectedTask,
    this.selectedAlert,
    this.bottomNavIndex = 0,
  });

  AppState copyWith({
    String? userLanguage,
    bool? isOffline,
    CropModel? selectedCrop,
    TaskModel? selectedTask,
    AlertModel? selectedAlert,
    int? bottomNavIndex,
  }) {
    return AppState(
      userLanguage: userLanguage ?? this.userLanguage,
      isOffline: isOffline ?? this.isOffline,
      selectedCrop: selectedCrop,
      selectedTask: selectedTask,
      selectedAlert: selectedAlert,
      bottomNavIndex: bottomNavIndex ?? this.bottomNavIndex,
    );
  }

  @override
  List<Object?> get props => [
        userLanguage,
        isOffline,
        selectedCrop,
        selectedTask,
        selectedAlert,
        bottomNavIndex,
      ];
}
