import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../../domain/usecases/alarm_usecases.dart';
import 'alarm_list_event.dart';
import 'alarm_list_state.dart';

class AlarmListBloc extends Bloc<AlarmListEvent, AlarmListState> {
  final AlarmUseCases _useCases;

  AlarmListBloc(this._useCases) : super(const AlarmListState()) {
    on<AlarmListStarted>(_onStarted);
    on<AlarmListToggled>(_onToggled);
    on<AlarmListDeleted>(_onDeleted);
  }

  Future<void> _onStarted(AlarmListStarted event, Emitter<AlarmListState> emit) async {
    emit(state.copyWith(status: AlarmListStatus.loading));

    await emit.forEach(
      _useCases.watchAlarms(),
      onData: (alarms) => state.copyWith(
        status: AlarmListStatus.loaded,
        alarms: alarms,
      ),
      onError: (e, s) => state.copyWith(
        status: AlarmListStatus.failure,
        errorMessage: e.toString(),
      ),
    );
  }

  Future<void> _onToggled(AlarmListToggled event, Emitter<AlarmListState> emit) async {
    await _useCases.toggleAlarm(alarm: event.alarm, enabled: event.enabled);
  }

  Future<void> _onDeleted(AlarmListDeleted event, Emitter<AlarmListState> emit) async {
    await _useCases.deleteAlarm(event.id);
  }
}
