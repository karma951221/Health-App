import 'package:app_shared/app_shared.dart';
import '../../entities/alarm.dart';
import '../../repositories/alarm_repository.dart';

class UpdateAlarmUseCase {
  final AlarmRepository _repository;

  UpdateAlarmUseCase(this._repository);

  Future<Result<Alarm, Failure>> call(Alarm alarm) {
    return _repository.updateAlarm(alarm);
  }
}
