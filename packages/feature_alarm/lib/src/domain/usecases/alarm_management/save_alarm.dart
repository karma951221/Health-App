import 'package:app_shared/app_shared.dart';
import '../../entities/alarm.dart';
import '../../extensions/alarm_extensions.dart';
import '../../repositories/alarm_repository.dart';
import '../../schedulers/alarm_ringer_service.dart';

class SaveAlarmUseCase {
  final AlarmRepository _repository;
  final AlarmRingerService _scheduler;
  final DateTime Function() _now;

  SaveAlarmUseCase(
    this._repository, {
    required AlarmRingerService scheduler,
    DateTime Function()? now,
  }) : _scheduler = scheduler,
       _now = now ?? DateTime.now;

  Future<Result<Alarm, Failure>> call(Alarm alarm) async {
    final newAlarm = alarm.withNextSchedule(_now());
    final result = await _repository.saveAlarm(newAlarm);
    
    Alarm? savedAlarm;
    result.when(success: (val) => savedAlarm = val, failure: (_) {});
    
    if (savedAlarm != null) {
      if (savedAlarm!.id != null) {
        await _scheduler.cancelAlarm(savedAlarm!.id!);
      }
      if (savedAlarm!.enabled && savedAlarm!.nextScheduledAt != null) {
        await _scheduler.scheduleAlarm(savedAlarm!);
      }
    }
    
    return result;
  }
}
