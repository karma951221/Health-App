import 'package:app_shared/app_shared.dart';
import '../entities/alarm.dart';

abstract interface class AlarmRepository {
  Stream<List<Alarm>> watchAlarms();
  Future<Result<Alarm, Failure>> saveAlarm(Alarm alarm);
  Future<Result<Alarm, Failure>> updateAlarm(Alarm alarm);
  Future<Result<void, Failure>> deleteAlarm(int id);
}
