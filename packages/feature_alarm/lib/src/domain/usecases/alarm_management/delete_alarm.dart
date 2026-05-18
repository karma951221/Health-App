import 'package:app_shared/app_shared.dart';
import '../../repositories/alarm_repository.dart';

class DeleteAlarmUseCase {
  final AlarmRepository _repository;

  DeleteAlarmUseCase(this._repository);

  Future<Result<void, Failure>> call(int id) {
    return _repository.deleteAlarm(id);
  }
}
