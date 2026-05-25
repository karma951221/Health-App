import 'dart:convert';
import '../entities/alarm_notification_payload.dart';

extension AlarmNotificationPayloadExtension on AlarmNotificationPayload {
  String toJsonString() {
    final map = toJson();
    map['type'] = AlarmNotificationPayload.type;
    return jsonEncode(map);
  }
}

extension AlarmNotificationPayloadStringExtension on String {
  AlarmNotificationPayload? toAlarmPayload() {
    if (isEmpty) return null;

    try {
      final decoded = jsonDecode(this);
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['type'] != AlarmNotificationPayload.type) return null;

      return AlarmNotificationPayload.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
