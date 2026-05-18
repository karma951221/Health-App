import '../../entities/alarm.dart';
import '../../repositories/alarm_repository.dart';

class WatchAlarmsUseCase {
  final AlarmRepository _repository;

  WatchAlarmsUseCase(this._repository);

  Stream<List<Alarm>> call() {
    return _repository.watchAlarms();
  }
}
