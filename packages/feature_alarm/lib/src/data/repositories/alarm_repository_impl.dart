import 'package:app_shared/app_shared.dart';
import 'package:infra_local_db/infra_local_db.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../mappers/alarm_mapper.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmLocalDataSource _dataSource;

  AlarmRepositoryImpl(this._dataSource);

  @override
  Stream<List<Alarm>> watchAlarms() {
    return _dataSource.watchAll().map(
          (list) => list.map((data) => data.toEntity()).toList(),
        );
  }

  @override
  Future<Result<Alarm, Failure>> saveAlarm(Alarm alarm) async {
    final result = await _dataSource.save(alarm.toTableData());
    return result.map((data) => data.toEntity());
  }

  @override
  Future<Result<Alarm, Failure>> updateAlarm(Alarm alarm) async {
    final result = await _dataSource.update(alarm.toTableData());
    return result.map((data) => data.toEntity());
  }

  @override
  Future<Result<void, Failure>> deleteAlarm(int id) {
    return _dataSource.deleteById(id);
  }
}
