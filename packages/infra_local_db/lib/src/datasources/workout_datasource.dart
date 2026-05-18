import 'package:app_shared/app_shared.dart';
import 'datasource.dart';
import '../db/app_database.dart';

class WorkoutLocalDataSource implements DataSource<WorkoutTableData> {
  final AppDatabase _db;

  WorkoutLocalDataSource(this._db);

  @override
  Stream<List<WorkoutTableData>> watchAll() {
    return _db.select(_db.workoutTable).watch();
  }

  @override
  Future<Result<WorkoutTableData, Failure>> findById(int id) async {
    try {
      final query = _db.select(_db.workoutTable)..where((t) => t.id.equals(id));
      final result = await query.getSingleOrNull();
      if (result != null) {
        return Result.success(result);
      } else {
        return Result.failure(Failure.notFound(message: 'Workout not found: $id'));
      }
    } catch (e) {
      return Result.failure(Failure.database(message: e.toString()));
    }
  }

  @override
  Future<Result<WorkoutTableData, Failure>> save(WorkoutTableData item) async {
    try {
      final id = await _db.into(_db.workoutTable).insert(item);
      return findById(id);
    } catch (e) {
      return Result.failure(Failure.database(message: e.toString()));
    }
  }

  @override
  Future<Result<WorkoutTableData, Failure>> update(WorkoutTableData item) async {
    try {
      final success = await _db.update(_db.workoutTable).replace(item);
      if (success) {
        return Result.success(item);
      } else {
        return Result.failure(Failure.notFound(message: 'Workout not found for update: ${item.id}'));
      }
    } catch (e) {
      return Result.failure(Failure.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> deleteById(int id) async {
    try {
      final count = await (_db.delete(_db.workoutTable)..where((t) => t.id.equals(id))).go();
      if (count > 0) {
        return Result.success(null);
      } else {
        return Result.failure(Failure.notFound(message: 'Workout not found for deletion: $id'));
      }
    } catch (e) {
      return Result.failure(Failure.database(message: e.toString()));
    }
  }
}
