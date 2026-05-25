import 'package:app_shared/app_shared.dart';
import '../../repositories/alarm_repository.dart';
import '../../schedulers/alarm_ringer_service.dart';

class DeleteAlarmUseCase {
  final AlarmRepository _repository;
  final AlarmRingerService _scheduler;

  DeleteAlarmUseCase(this._repository, {required AlarmRingerService scheduler})
      : _scheduler = scheduler;

  Future<Result<void, Failure>> call(int id) async {
    final result = await _repository.deleteAlarm(id);
    
    bool deleted = false;
    result.when(success: (_) => deleted = true, failure: (_) {});
    
    if (deleted) {
      await _scheduler.cancelAlarm(id);
    }
    return result;
  }
}
