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
/// Each domain alarm maps to a single native alarm fired at its
/// [Alarm.nextScheduledAt]. Repeating alarms are advanced to their next
/// occurrence by the app layer when they are dismissed.
class AlarmRingerServiceImpl implements AlarmRingerService {
  // TODO(custom-sound): audioPath를 외부에서 주입받아 커스텀 음원을 지원한다.
  // main.dart의 AlarmRingerServiceImpl() 생성 시 audioPath 인자를 추가하면 된다.
  AlarmRingerServiceImpl({String? audioPath}) : _audioPath = audioPath;

  final String? _audioPath;
  StreamSubscription<alarm_pkg.AlarmSet>? _ringingSubscription;

  /// Subscribes to ring events. [onRing] is invoked once per ringing alarm
  /// with the decoded payload (used to open the ringing screen).
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

  @override
  Future<void> rescheduleAll(List<Alarm> alarms) async {
    for (final alarm in alarms) {
      if (alarm.enabled && alarm.nextScheduledAt != null) {
        await scheduleAlarm(alarm);
      }
    }
  }

  /// Stops a currently ringing (or scheduled) alarm.
  Future<void> stop(int alarmId) async {
    await alarm_pkg.Alarm.stop(alarmId);
  }

  void dispose() {
    _ringingSubscription?.cancel();
    _ringingSubscription = null;
  }
}
