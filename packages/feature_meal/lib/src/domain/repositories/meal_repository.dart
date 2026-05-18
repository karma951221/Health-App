import 'package:app_shared/app_shared.dart';
import '../entities/meal.dart';

abstract interface class MealRepository {
  Stream<List<Meal>> watchMeals();
  Future<Result<Meal, Failure>> saveMeal(Meal meal);
  Future<Result<Meal, Failure>> updateMeal(Meal meal);
  Future<Result<void, Failure>> deleteMeal(int id);
}
