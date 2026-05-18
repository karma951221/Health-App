import '../repositories/alarm_repository.dart';
import 'alarm_management/delete_alarm.dart';
import 'alarm_management/save_alarm.dart';
import 'alarm_management/toggle_alarm.dart';
import 'alarm_management/update_alarm.dart';
import 'alarm_monitoring/watch_alarms.dart';

class AlarmUseCases {
  final AlarmRepository _repository;

  AlarmUseCases(this._repository);

  WatchAlarmsUseCase get watchAlarms => WatchAlarmsUseCase(_repository);
  SaveAlarmUseCase get saveAlarm => SaveAlarmUseCase(_repository);
  UpdateAlarmUseCase get updateAlarm => UpdateAlarmUseCase(_repository);
  DeleteAlarmUseCase get deleteAlarm => DeleteAlarmUseCase(_repository);
  ToggleAlarmUseCase get toggleAlarm => ToggleAlarmUseCase(_repository);
}
