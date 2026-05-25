import 'dart:async';

import 'package:alarm/alarm.dart' as alarm_pkg;
import 'package:alarm/utils/alarm_set.dart' as alarm_pkg;

import '../../domain/entities/alarm_notification_payload.dart';
import '../../domain/extensions/alarm_payload_extensions.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/schedulers/alarm_ringer_service.dart';
import 'alarm_settings_mapper.dart';

/// [AlarmRingerService] implementation backed by the `alarm` package.
///
/// drift가 유일한 진실. 이 구현은 drift 알람을 OS 스케줄로 투영할 뿐이며,
/// 목록을 alarm 패키지에서 읽지 않는다.
///
/// Each domain alarm maps to a single native alarm fired at its
/// [Alarm.nextScheduledAt]. Repeating alarms are advanced to their next
/// occurrence by the app layer when they are dismissed.
class AlarmRingerServiceImpl implements AlarmRingerService {
  // TODO(custom-sound): audioPath를 외부에서 주입받아 커스텀 음원을 지원한다.
  AlarmRingerServiceImpl({String? audioPath}) : _audioPath = audioPath;

  final String? _audioPath;
  StreamSubscription<alarm_pkg.AlarmSet>? _ringingSubscription;

  @override
  void listenForRinging(void Function(AlarmNotificationPayload payload) onRing) {
    _ringingSubscription?.cancel();
    _ringingSubscription = alarm_pkg.Alarm.ringing.listen((alarmSet) {
      for (final ringing in alarmSet.alarms) {
        final payload = ringing.payload?.toAlarmPayload();
        if (payload != null) {
          onRing(payload);
        }
      }
    });
  }

  @override
  Future<void> scheduleAlarm(Alarm alarm) async {
    if (!alarm.enabled || alarm.id == null || alarm.nextScheduledAt == null) {
      return;
    }
    await alarm_pkg.Alarm.set(
      alarmSettings: alarm.toSettings(audioPath: _audioPath),
    );
  }

  @override
  Future<void> cancelAlarm(int alarmId) async {
    await alarm_pkg.Alarm.stop(alarmId);
  }

  /// OS 예약 상태를 [alarms](drift 스냅샷)와 일치(reconcile)시킨다.
  ///
  /// "원하는 집합" = enabled && id != null && nextScheduledAt != null.
  /// 고아(OS에 있으나 원하는 집합에 없음) → 취소.
  /// 누락/변경(원하는 집합에 있으나 OS에 없거나 dateTime 불일치) → 예약.
  /// 이미 올바른 항목 → 건드리지 않음(콜드 스타트 중 울리는 알람 보호).
  @override
  Future<void> syncFromStore(List<Alarm> alarms) async {
    final desired = <int, Alarm>{
      for (final a in alarms)
        if (a.enabled && a.id != null && a.nextScheduledAt != null) a.id!: a,
    };

    final scheduled = await alarm_pkg.Alarm.getAlarms();

    // 고아 취소: OS엔 있으나 store가 원하지 않음
    for (final s in scheduled) {
      if (!desired.containsKey(s.id)) {
        await alarm_pkg.Alarm.stop(s.id);
      }
    }

    // 누락/변경분만 예약: 이미 같은 시각으로 걸린 건 건드리지 않음
    for (final alarm in desired.values) {
      final existing = scheduled.where((s) => s.id == alarm.id).firstOrNull;
      if (existing == null || existing.dateTime != alarm.nextScheduledAt) {
        await scheduleAlarm(alarm);
      }
    }
  }

  @override
  Future<void> stop(int alarmId) async {
    await alarm_pkg.Alarm.stop(alarmId);
  }

  void dispose() {
    _ringingSubscription?.cancel();
    _ringingSubscription = null;
  }
}
