import '../entities/alarm.dart';
import '../entities/alarm_notification_payload.dart';

/// drift가 유일한 진실(source of truth).
/// 이 서비스는 drift의 알람을 OS 스케줄로 투영할 뿐이며, 목록을 alarm 패키지에서 읽지 않는다.
abstract interface class AlarmRingerService {
  Future<void> scheduleAlarm(Alarm alarm);
  Future<void> cancelAlarm(int alarmId);

  /// OS 예약 상태를 [alarms](drift 스냅샷)와 일치시킨다.
  ///
  /// - `enabled && nextScheduledAt != null`인 알람만 "원하는 집합"으로 간주.
  /// - OS에 있으나 원하는 집합에 없는 항목(고아) → 취소.
  /// - 원하는 집합에 있으나 OS에 없거나 `dateTime`이 다른 항목 → 예약.
  /// - 이미 올바르게 예약된 항목 → 건드리지 않음(콜드 스타트 중 울리는 알람 보호).
  Future<void> syncFromStore(List<Alarm> alarms);

  void listenForRinging(void Function(AlarmNotificationPayload payload) onRing);
  Future<void> stop(int alarmId);
}
