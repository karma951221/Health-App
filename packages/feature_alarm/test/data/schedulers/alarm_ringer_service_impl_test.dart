import 'package:feature_alarm/src/data/schedulers/alarm_settings_mapper.dart';
import 'package:feature_alarm/feature_alarm.dart';
import 'package:feature_alarm/src/domain/extensions/alarm_payload_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

Alarm _alarm({
  int? id = 7,
  int hour = 6,
  int minute = 30,
  int weekdayMask = 0,
  String label = '아침',
  int shakeCount = 25,
  DateTime? nextScheduledAt,
}) {
  return Alarm(
    id: id,
    hour: hour,
    minute: minute,
    weekdayMask: weekdayMask,
    oneShotDate: null,
    nextScheduledAt: nextScheduledAt ?? DateTime(2026, 5, 25, 6, 30),
    enabled: true,
    shakeCount: shakeCount,
    label: label,
  );
}

void main() {
  group('alarmSettingsFrom', () {
    test('toSettings maps a domain alarm to looping, vibrating, full-screen settings', () {
      final alarm = Alarm(
        id: 1,
        hour: 9,
        minute: 0,
        weekdayMask: 0,
        nextScheduledAt: DateTime(2026, 5, 25, 9),
        enabled: true,
        shakeCount: 20,
        label: 'Wake Up!',
      );

      final settings = alarm.toSettings();
      expect(settings.id, 1);
      expect(settings.dateTime, DateTime(2026, 5, 25, 9));
      expect(settings.loopAudio, isTrue);
      expect(settings.vibrate, isTrue);
      expect(settings.androidFullScreenIntent, isTrue);
    });

    test('encodes ring-screen data into the payload', () {
      final settings = alarmSettingsFrom(
        _alarm(id: 7, hour: 6, minute: 30, label: '아침', shakeCount: 25),
      );

      final payload = settings.payload.toAlarmPayload();
      expect(payload?.alarmId, 7);
      expect(payload?.hour, 6);
      expect(payload?.minute, 30);
      expect(payload?.label, '아침');
      expect(payload?.shakeCount, 25);
    });

    test('uses the device default sound when no audio path is given', () {
      final settings = alarmSettingsFrom(_alarm());
      expect(settings.assetAudioPath, isNull);
    });

    test('uses the provided audio path', () {
      final settings = alarmSettingsFrom(
        _alarm(),
        audioPath: 'assets/audio/alarm.mp3',
      );
      expect(settings.assetAudioPath, 'assets/audio/alarm.mp3');
    });
  });
}
