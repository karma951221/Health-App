import 'package:app_shared/app_shared.dart';
import 'package:infra_local_db/infra_local_db.dart';
import '../../domain/entities/workout.dart';
import '../../domain/repositories/workout_repository.dart';
import '../mappers/workout_mapper.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDataSource _dataSource;

  WorkoutRepositoryImpl(this._dataSource);

  @override
  Stream<List<Workout>> watchWorkouts() {
    return _dataSource.watchAll().map(
          (list) => list.map((data) => data.toEntity()).toList(),
        );
  }

  @override
  Future<Result<Workout, Failure>> saveWorkout(Workout workout) async {
    final result = await _dataSource.save(workout.toTableData());
    return result.map((data) => data.toEntity());
  }

  @override
  Future<Result<Workout, Failure>> updateWorkout(Workout workout) async {
    final result = await _dataSource.update(workout.toTableData());
    return result.map((data) => data.toEntity());
  }

  @override
  Future<Result<void, Failure>> deleteWorkout(int id) {
    return _dataSource.deleteById(id);
  }
}
