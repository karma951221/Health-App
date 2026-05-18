import 'package:app_shared/app_shared.dart';
import '../../entities/alarm.dart';
import '../../repositories/alarm_repository.dart';

class SaveAlarmUseCase {
  final AlarmRepository _repository;

  SaveAlarmUseCase(this._repository);

  Future<Result<Alarm, Failure>> call(Alarm alarm) {
    return _repository.saveAlarm(alarm);
  }
}
