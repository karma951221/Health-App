import 'package:app_shared/app_shared.dart';
import 'datasource.dart';
import '../db/app_database.dart';

class MealLocalDataSource implements DataSource<MealTableData> {
  final AppDatabase _db;

  MealLocalDataSource(this._db);

  @override
  Stream<List<MealTableData>> watchAll() {
    return _db.select(_db.mealTable).watch();
  }

  @override
  Future<Result<MealTableData, Failure>> findById(int id) async {
    try {
      final query = _db.select(_db.mealTable)..where((t) => t.id.equals(id));
      final result = await query.getSingleOrNull();
      if (result != null) {
        return Result.success(result);
      } else {
        return Result.failure(Failure.notFound(message: 'Meal not found: $id'));
      }
    } catch (e) {
      return Result.failure(Failure.database(message: e.toString()));
    }
  }

  @override
  Future<Result<MealTableData, Failure>> save(MealTableData item) async {
    try {
      final id = await _db.into(_db.mealTable).insert(item);
      return findById(id);
    } catch (e) {
      return Result.failure(Failure.database(message: e.toString()));
    }
  }

  @override
  Future<Result<MealTableData, Failure>> update(MealTableData item) async {
    try {
      final success = await _db.update(_db.mealTable).replace(item);
      if (success) {
        return Result.success(item);
      } else {
        return Result.failure(Failure.notFound(message: 'Meal not found for update: ${item.id}'));
      }
    } catch (e) {
      return Result.failure(Failure.database(message: e.toString()));
    }
  }

  @override
  Future<Result<void, Failure>> deleteById(int id) async {
    try {
      final count = await (_db.delete(_db.mealTable)..where((t) => t.id.equals(id))).go();
      if (count > 0) {
        return Result.success(null);
      } else {
        return Result.failure(Failure.notFound(message: 'Meal not found for deletion: $id'));
      }
    } catch (e) {
      return Result.failure(Failure.database(message: e.toString()));
    }
  }
}
