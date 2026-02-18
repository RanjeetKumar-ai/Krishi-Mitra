/// App BLoC - Global state management
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<SelectCropEvent>(_onSelectCrop);
    on<SelectTaskEvent>(_onSelectTask);
    on<SelectAlertEvent>(_onSelectAlert);
    on<ChangeBottomNavIndexEvent>(_onChangeBottomNavIndex);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<UpdateOfflineStatusEvent>(_onUpdateOfflineStatus);
  }

  void _onSelectCrop(SelectCropEvent event, Emitter<AppState> emit) {
    emit(state.copyWith(selectedCrop: event.crop));
  }

  void _onSelectTask(SelectTaskEvent event, Emitter<AppState> emit) {
    emit(state.copyWith(selectedTask: event.task));
  }

  void _onSelectAlert(SelectAlertEvent event, Emitter<AppState> emit) {
    emit(state.copyWith(selectedAlert: event.alert));
  }

  void _onChangeBottomNavIndex(
      ChangeBottomNavIndexEvent event, Emitter<AppState> emit) {
    emit(state.copyWith(bottomNavIndex: event.index));
  }

  void _onChangeLanguage(ChangeLanguageEvent event, Emitter<AppState> emit) {
    emit(state.copyWith(userLanguage: event.language));
  }

  void _onUpdateOfflineStatus(
      UpdateOfflineStatusEvent event, Emitter<AppState> emit) {
    emit(state.copyWith(isOffline: event.isOffline));
  }
}
