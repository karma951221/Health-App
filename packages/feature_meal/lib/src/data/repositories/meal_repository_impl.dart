import 'package:app_shared/app_shared.dart';
import 'package:infra_local_db/infra_local_db.dart';
import '../../domain/entities/meal.dart';
import '../../domain/repositories/meal_repository.dart';
import '../mappers/meal_mapper.dart';

class MealRepositoryImpl implements MealRepository {
  final MealLocalDataSource _dataSource;

  MealRepositoryImpl(this._dataSource);

  @override
  Stream<List<Meal>> watchMeals() {
    return _dataSource.watchAll().map(
          (list) => list.map((data) => data.toEntity()).toList(),
        );
  }

  @override
  Future<Result<Meal, Failure>> saveMeal(Meal meal) async {
    final result = await _dataSource.save(meal.toTableData());
    return result.map((data) => data.toEntity());
  }

  @override
  Future<Result<Meal, Failure>> updateMeal(Meal meal) async {
    final result = await _dataSource.update(meal.toTableData());
    return result.map((data) => data.toEntity());
  }

  @override
  Future<Result<void, Failure>> deleteMeal(int id) {
    return _dataSource.deleteById(id);
  }
}
