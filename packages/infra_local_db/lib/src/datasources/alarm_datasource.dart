import 'package:app_shared/app_shared.dart';
import 'package:drift/drift.dart';
import 'datasource.dart';
import '../db/app_database.dart';

class AlarmLocalDataSource implements DataSource<AlarmTableData> {
  final AppDatabase _db;

  AlarmLocalDataSource(this._db);

  @override
  Stream<List<AlarmTableData>> watchAll() {
    return _db.select(_db.alarmTable).watch();
  }

  @override
  Future<Result<AlarmTableData, Failure>> findById(int id) async {
    try {
      final query = _db.select(_db.alarmTable)..where((t) => t.id.equals(id));
      final result = await query.getSingleOrNull();
      if (result != null) {
        return Result.success(result);
      } else {
        return Result.failure(Failure.notFound(message: 'Alarm not found: $id'));
      }
    } catch (e) {
      return Result.failure(Failure.database(message: e.toString()));
    }
  }

  @override
  Future<Result<AlarmTableData, Failure>> save(AlarmTableData item) async {
    try {
      final id = await _db.into(_db.alarmTable).insert(
            AlarmTableCompanion.insert(
              hour: item.hour,
              minute: item.minute,
              weekdayMask: item.weekdayMask,
              oneShotDate: Value(item.oneShotDate),
              nextScheduledAt: Value(item.nextScheduledAt),
              enabled: Value(item.enabled),
              shakeCount: Value(item.shakeCount),
              label: item.label,
            ),
          );
      return findById(id);
    } catch (e) {
      return Result.failure(Failure.database(message: e.toString()));
    }
  }

  @override
  Future<Result<AlarmTableData, Failure>> update(AlarmTableData item) async {
    try {
      final success = await _db.update(_db.alarmTable).replace(item);
      if (success) {
        return Result.success(item);
      } else {
        return Result.failure(Failure.notFound(message: 'Alarm not found for update: ${item.id}'));
      }
    } catch (e) {
      return Result.failure(Failure.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> deleteById(int id) async {
    try {
      final count = await (_db.delete(_db.alarmTable)..where((t) => t.id.equals(id))).go();
      if (count > 0) {
        return Result.success(null);
      } else {
        return Result.failure(Failure.notFound(message: 'Alarm not found for deletion: $id'));
      }
    } catch (e) {
      return Result.failure(Failure.database(message: e.toString()));
    }
  }
}
