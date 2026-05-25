import '../entities/alarm.dart';
import '../entities/alarm_notification_payload.dart';

abstract interface class AlarmRingerService {
  Future<void> scheduleAlarm(Alarm alarm);
  Future<void> cancelAlarm(int alarmId);
  Future<void> rescheduleAll(List<Alarm> alarms);
  void listenForRinging(void Function(AlarmNotificationPayload payload) onRing);
  Future<void> stop(int alarmId);
}
