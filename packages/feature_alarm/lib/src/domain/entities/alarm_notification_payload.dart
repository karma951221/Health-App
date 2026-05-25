import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'alarm_notification_payload.freezed.dart';
part 'alarm_notification_payload.g.dart';

@freezed
@JsonSerializable()
class AlarmNotificationPayload with _$AlarmNotificationPayload {
  const AlarmNotificationPayload({
    required this.alarmId,
    required this.hour,
    required this.minute,
    required this.label,
    required this.shakeCount,
  });

  final int alarmId;
  final int hour;
  final int minute;
  final String label;
  final int shakeCount;

  factory AlarmNotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$AlarmNotificationPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$AlarmNotificationPayloadToJson(this);

  static const type = 'alarm';
}
