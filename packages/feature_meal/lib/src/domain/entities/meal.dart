import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal.freezed.dart';
part 'meal.g.dart';

@freezed
@JsonSerializable()
class Meal with _$Meal {
  const Meal({
    this.id,
    required this.loggedAt,
    required this.memo,
    this.photoPath,
  });

  final int? id;
  final DateTime loggedAt;
  final String memo;
  final String? photoPath;

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);
}
