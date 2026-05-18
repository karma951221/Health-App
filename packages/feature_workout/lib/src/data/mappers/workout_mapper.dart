import 'package:infra_local_db/infra_local_db.dart';
import '../../domain/entities/workout.dart';

extension WorkoutMapper on WorkoutTableData {
  Workout toEntity() {
    return Workout(
      id: id,
      loggedAt: loggedAt,
      memo: memo,
    );
  }
}

extension WorkoutEntityMapper on Workout {
  WorkoutTableData toTableData() {
    return WorkoutTableData(
      id: id ?? 0,
      loggedAt: loggedAt,
      memo: memo,
    );
  }
}
