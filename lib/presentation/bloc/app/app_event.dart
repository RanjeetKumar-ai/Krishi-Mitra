/// App Events
library;

import 'package:equatable/equatable.dart';
import '../../../core/models/crop_model.dart';
import '../../../core/models/task_model.dart';
import '../../../core/models/alert_model.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class SelectCropEvent extends AppEvent {
  final CropModel crop;
  const SelectCropEvent(this.crop);

  @override
  List<Object?> get props => [crop];
}

class SelectTaskEvent extends AppEvent {
  final TaskModel task;
  const SelectTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class SelectAlertEvent extends AppEvent {
  final AlertModel alert;
  const SelectAlertEvent(this.alert);

  @override
  List<Object?> get props => [alert];
}

class ChangeBottomNavIndexEvent extends AppEvent {
  final int index;
  const ChangeBottomNavIndexEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class ChangeLanguageEvent extends AppEvent {
  final String language;
  const ChangeLanguageEvent(this.language);

  @override
  List<Object?> get props => [language];
}

class UpdateOfflineStatusEvent extends AppEvent {
  final bool isOffline;
  const UpdateOfflineStatusEvent(this.isOffline);

  @override
  List<Object?> get props => [isOffline];
}
