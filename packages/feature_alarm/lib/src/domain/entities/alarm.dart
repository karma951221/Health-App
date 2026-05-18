import 'package:freezed_annotation/freezed_annotation.dart';

part 'alarm.freezed.dart';
part 'alarm.g.dart';

@freezed
@JsonSerializable()
class Alarm with _$Alarm {
  const Alarm({
    this.id,
    required this.hour,
    required this.minute,
    required this.weekdayMask,
    this.oneShotDate,
    this.nextScheduledAt,
    required this.enabled,
    required this.shakeCount,
    required this.label,
  });

  final int? id;
  final int hour;
  final int minute;
  final int weekdayMask;
  final DateTime? oneShotDate;
  final DateTime? nextScheduledAt;
  final bool enabled;
  final int shakeCount;
  final String label;

  factory Alarm.fromJson(Map<String, dynamic> json) => _$AlarmFromJson(json);
}
