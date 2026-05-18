import 'package:infra_local_db/infra_local_db.dart';
import '../../domain/entities/meal.dart';

extension MealMapper on MealTableData {
  Meal toEntity() {
    return Meal(
      id: id,
      loggedAt: loggedAt,
      memo: memo,
      photoPath: photoPath,
    );
  }
}

extension MealEntityMapper on Meal {
  MealTableData toTableData() {
    return MealTableData(
      id: id ?? 0,
      loggedAt: loggedAt,
      memo: memo,
      photoPath: photoPath,
    );
  }
}
