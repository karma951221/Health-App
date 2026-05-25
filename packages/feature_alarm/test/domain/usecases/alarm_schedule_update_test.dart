import 'package:app_shared/app_shared.dart';
import 'package:feature_alarm/feature_alarm.dart';
import 'package:flutter_test/flutter_test.dart';

Alarm _alarm({
  int? id,
  int hour = 9,
  int minute = 0,
  int weekdayMask = 0,
  bool enabled = true,
  DateTime? nextScheduledAt,
}) {
  return Alarm(
    id: id,
    hour: hour,
    minute: minute,
    weekdayMask: weekdayMask,
    oneShotDate: null,
    nextScheduledAt: nextScheduledAt,
    enabled: enabled,
    shakeCount: 20,
    label: '',
  );
}

class _FakeAlarmRepository implements AlarmRepository {
  Alarm? savedAlarm;
  Alarm? updatedAlarm;

  @override
  Future<Result<void, Failure>> deleteAlarm(int id) async {
    return Result.success(null);
  }

  @override
  Future<Result<Alarm, Failure>> saveAlarm(Alarm alarm) async {
    savedAlarm = alarm;
    return Result.success(alarm.copyWith(id: 1));
  }

  @override
  Future<Result<Alarm, Failure>> updateAlarm(Alarm alarm) async {
    updatedAlarm = alarm;
    return Result.success(alarm);
  }

  @override
  Stream<List<Alarm>> watchAlarms() {
    return const Stream.empty();
  }
}

class _FakeAlarmRingerService implements AlarmRingerService {
  final List<Alarm> scheduled = [];

  @override
  Future<void> cancelAlarm(int alarmId) async {}

  @override
  Future<void> syncFromStore(List<Alarm> alarms) async {}

  @override
  Future<void> scheduleAlarm(Alarm alarm) async {
    scheduled.add(alarm);
  }

  @override
  void listenForRinging(void Function(AlarmNotificationPayload payload) onRing) {}

  @override
  Future<void> stop(int alarmId) async {}
}

void main() {
  final now = DateTime(2026, 5, 25, 8);

  group('nextScheduledAt updates', () {
    test('save fills the next occurrence for enabled alarms', () async {
      final repository = _FakeAlarmRepository();
      final useCases = AlarmUseCases(repository, scheduler: _FakeAlarmRingerService(), now: () => now);

      await useCases.saveAlarm(_alarm(hour: 9, minute: 30));

      expect(
        repository.savedAlarm?.nextScheduledAt,
        DateTime(2026, 5, 25, 9, 30),
      );
    });

    test('update recalculates the next occurrence', () async {
      final repository = _FakeAlarmRepository();
      final useCases = AlarmUseCases(repository, scheduler: _FakeAlarmRingerService(), now: () => now);

      await useCases.updateAlarm(
        _alarm(id: 1, hour: 7, minute: 0, nextScheduledAt: DateTime(2020)),
      );

      expect(
        repository.updatedAlarm?.nextScheduledAt,
        DateTime(2026, 5, 26, 7),
      );
    });

    test('toggle on fills nextScheduledAt', () async {
      final repository = _FakeAlarmRepository();
      final useCases = AlarmUseCases(repository, scheduler: _FakeAlarmRingerService(), now: () => now);

      await useCases.toggleAlarm(
        alarm: _alarm(id: 1, enabled: false),
        enabled: true,
      );

      expect(repository.updatedAlarm?.enabled, isTrue);
      expect(
        repository.updatedAlarm?.nextScheduledAt,
        DateTime(2026, 5, 25, 9),
      );
    });

    test('toggle off clears nextScheduledAt', () async {
      final repository = _FakeAlarmRepository();
      final useCases = AlarmUseCases(repository, scheduler: _FakeAlarmRingerService(), now: () => now);

      await useCases.toggleAlarm(
        alarm: _alarm(id: 1, nextScheduledAt: DateTime(2026, 5, 25, 9)),
        enabled: false,
      );

      expect(repository.updatedAlarm?.enabled, isFalse);
      expect(repository.updatedAlarm?.nextScheduledAt, isNull);
    });
  });
}
