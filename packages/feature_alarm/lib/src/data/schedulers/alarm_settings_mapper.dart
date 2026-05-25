import 'package:alarm/alarm.dart' as alarm_pkg;

import '../../domain/entities/alarm_notification_payload.dart';
import '../../domain/extensions/alarm_payload_extensions.dart';
import '../../domain/entities/alarm.dart';

extension AlarmSettingsExtension on Alarm {
  /// Maps a domain [Alarm] to the `alarm` package's `AlarmSettings`.
  ///
  /// Requires [Alarm.id] and [Alarm.nextScheduledAt] to be non-null — callers
  /// must guard before scheduling.
  alarm_pkg.AlarmSettings toSettings({String? audioPath}) {
    if (id == null) {
      throw ArgumentError('Alarm id must not be null when scheduling');
    }
    if (nextScheduledAt == null) {
      throw ArgumentError('nextScheduledAt must not be null when scheduling');
    }

    final payload = AlarmNotificationPayload(
      alarmId: id!,
      hour: hour,
      minute: minute,
      label: label,
      shakeCount: shakeCount,
    );

    return alarm_pkg.AlarmSettings(
      id: id!,
      dateTime: nextScheduledAt!,
      // TODO(custom-sound): 커스텀 알람음 설정 기능 구현 시 audioPath를 채운다.
      // 현재는 null → 기기 기본 알람음으로 울림.
      assetAudioPath: audioPath,
      loopAudio: true,
      vibrate: true,
      androidFullScreenIntent: true,
      // Native AlarmManager keeps the alarm alive after the app is killed.
      warningNotificationOnKill: false,
      androidStopAlarmOnTermination: false,
      volumeSettings: alarm_pkg.VolumeSettings.fade(
        volume: 1,
        fadeDuration: const Duration(seconds: 5),
        volumeEnforced: true,
      ),
      notificationSettings: alarm_pkg.NotificationSettings(
        title: label.isEmpty ? '알람' : label,
        body: '$shakeCount번 흔들어서 해제하세요.',
        stopButton: '해제',
      ),
      payload: payload.toJsonString(),
    );
  }
}
