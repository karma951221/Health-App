import 'package:feature_alarm/feature_alarm.dart';
import 'package:feature_alarm/src/domain/extensions/alarm_payload_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('encodes and decodes alarm payload', () {
    const payload = AlarmNotificationPayload(
      alarmId: 7,
      hour: 6,
      minute: 30,
      label: '아침 알람',
      shakeCount: 25,
    );

    final decoded = payload.toJsonString().toAlarmPayload();

    expect(decoded?.alarmId, 7);
    expect(decoded?.hour, 6);
    expect(decoded?.minute, 30);
    expect(decoded?.label, '아침 알람');
    expect(decoded?.shakeCount, 25);
  });

  test('returns null for non-alarm payload', () {
    expect('{"type":"other"}'.toAlarmPayload(), isNull);
    expect('not json'.toAlarmPayload(), isNull);
  });
}
