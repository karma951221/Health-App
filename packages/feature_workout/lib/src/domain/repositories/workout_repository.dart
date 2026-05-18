import 'package:app_shared/app_shared.dart';
import '../entities/workout.dart';

abstract interface class WorkoutRepository {
  Stream<List<Workout>> watchWorkouts();
  Future<Result<Workout, Failure>> saveWorkout(Workout workout);
  Future<Result<Workout, Failure>> updateWorkout(Workout workout);
  Future<Result<void, Failure>> deleteWorkout(int id);
}
