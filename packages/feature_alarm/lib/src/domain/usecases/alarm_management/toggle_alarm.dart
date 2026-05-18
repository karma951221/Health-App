import 'package:app_shared/app_shared.dart';
import '../../entities/alarm.dart';
import '../../repositories/alarm_repository.dart';

class ToggleAlarmUseCase {
  final AlarmRepository _repository;

  ToggleAlarmUseCase(this._repository);

  Future<Result<Alarm, Failure>> call({required Alarm alarm, required bool enabled}) {
    final updatedAlarm = alarm.copyWith(enabled: enabled);
    return _repository.updateAlarm(updatedAlarm);
  }
}
