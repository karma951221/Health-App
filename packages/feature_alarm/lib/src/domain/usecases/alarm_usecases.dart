import '../repositories/alarm_repository.dart';
import '../schedulers/alarm_ringer_service.dart';
import 'alarm_management/delete_alarm.dart';
import 'alarm_management/save_alarm.dart';
import 'alarm_management/toggle_alarm.dart';
import 'alarm_management/update_alarm.dart';
import 'alarm_monitoring/watch_alarms.dart';

class AlarmUseCases {
  final AlarmRepository _repository;
  final AlarmRingerService _scheduler;
  final DateTime Function() _now;

  AlarmUseCases(
    this._repository, {
    required AlarmRingerService scheduler,
    DateTime Function()? now,
  }) : _scheduler = scheduler,
       _now = now ?? DateTime.now;

  WatchAlarmsUseCase get watchAlarms => WatchAlarmsUseCase(_repository);
  SaveAlarmUseCase get saveAlarm => SaveAlarmUseCase(
    _repository,
    scheduler: _scheduler,
    now: _now,
  );
  UpdateAlarmUseCase get updateAlarm => UpdateAlarmUseCase(
    _repository,
    scheduler: _scheduler,
    now: _now,
  );
  DeleteAlarmUseCase get deleteAlarm => DeleteAlarmUseCase(
    _repository,
    scheduler: _scheduler,
  );
  ToggleAlarmUseCase get toggleAlarm => ToggleAlarmUseCase(
    _repository,
    scheduler: _scheduler,
    now: _now,
  );
}
