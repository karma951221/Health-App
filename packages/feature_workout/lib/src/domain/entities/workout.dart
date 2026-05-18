import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout.freezed.dart';
part 'workout.g.dart';

@freezed
@JsonSerializable()
class Workout with _$Workout {
  const Workout({
    this.id,
    required this.loggedAt,
    required this.memo,
  });

  final int? id;
  final DateTime loggedAt;
  final String memo;

  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);
}
