import 'package:bloc/bloc.dart';
import '../../../domain/usecases/alarm_usecases.dart';
import 'alarm_edit_state.dart';

class AlarmEditCubit extends Cubit<AlarmEditState> {
  final AlarmUseCases _useCases;

  AlarmEditCubit(this._useCases, {AlarmEditState? initialState})
      : super(initialState ?? AlarmEditState.initial());

  void updateTime(int hour, int minute) {
    emit(state.copyWith(
      alarm: state.alarm.copyWith(hour: hour, minute: minute),
    ));
  }

  void updateWeekdays(int mask) {
    emit(state.copyWith(
      alarm: state.alarm.copyWith(weekdayMask: mask),
    ));
  }

  void updateShakeCount(int count) {
    emit(state.copyWith(
      alarm: state.alarm.copyWith(shakeCount: count),
    ));
  }

  void updateLabel(String label) {
    emit(state.copyWith(
      alarm: state.alarm.copyWith(label: label),
    ));
  }

  Future<void> save() async {
    emit(state.copyWith(status: AlarmEditStatus.saving, errorMessage: null));

    final result = state.alarm.id == null
        ? await _useCases.saveAlarm(state.alarm)
        : await _useCases.updateAlarm(state.alarm);

    result.when(
      success: (alarm) => emit(state.copyWith(
        status: AlarmEditStatus.success,
        alarm: alarm,
      )),
      failure: (failure) => emit(state.copyWith(
        status: AlarmEditStatus.failure,
        errorMessage: failure.message,
      )),
    );
  }
}
