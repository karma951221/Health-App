import 'package:app_shared/app_shared.dart';
import 'package:feature_alarm/feature_alarm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_local_db/infra_local_db.dart';

Alarm _alarm({int? id = 1, bool enabled = true, DateTime? nextScheduledAt}) {
  return Alarm(
    id: id,
    hour: 7,
    minute: 0,
    weekdayMask: 0,
    oneShotDate: null,
    nextScheduledAt: nextScheduledAt ?? DateTime(2026, 5, 25, 7),
    enabled: enabled,
    shakeCount: 20,
    label: '',
  );
}

class _FakeAlarmLocalDataSource implements AlarmLocalDataSource {
  _FakeAlarmLocalDataSource({
    this.saveResult,
    this.updateResult,
    this.deleteResult,
  });

  Result<AlarmTableData, Failure>? saveResult;
  Result<AlarmTableData, Failure>? updateResult;
  Result<void, Failure>? deleteResult;

  @override
  Future<Result<void, Failure>> deleteById(int id) async {
    return deleteResult ?? Result.success(null);
  }

  @override
  Future<Result<AlarmTableData, Failure>> save(AlarmTableData item) async {
    return saveResult ??
        Result.success(
          item.copyWith(id: 1),
        ); // mimic DB assigning ID 1
  }

  @override
  Future<Result<AlarmTableData, Failure>> update(AlarmTableData item) async {
    return updateResult ?? Result.success(item);
  }

  @override
  Stream<List<AlarmTableData>> watchAll() => const Stream.empty();

  @override
  Future<Result<AlarmTableData, Failure>> findById(int id) async {
    return Result.failure(Failure.notFound(message: 'Not implemented in fake'));
  }
}

class _FakeAlarmRingerService implements AlarmRingerService {
  final scheduled = <Alarm>[];
  final canceled = <int>[];
  final rescheduled = <List<Alarm>>[];

  @override
  Future<void> cancelAlarm(int alarmId) async {
    canceled.add(alarmId);
  }

  @override
  Future<void> rescheduleAll(List<Alarm> alarms) async {
    rescheduled.add(alarms);
  }

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
  test('save success schedules alarm', () async {
    final scheduler = _FakeAlarmRingerService();
    final repo = AlarmRepositoryImpl(_FakeAlarmLocalDataSource());
    final useCases = AlarmUseCases(repo, scheduler: scheduler);

    await useCases.saveAlarm(_alarm(id: null));

    expect(scheduler.canceled, [1]);
    expect(scheduler.scheduled.single.id, 1);
  });

  test('update success cancels but does not schedule disabled alarms', () async {
    final scheduler = _FakeAlarmRingerService();
    final repo = AlarmRepositoryImpl(_FakeAlarmLocalDataSource());
    final useCases = AlarmUseCases(repo, scheduler: scheduler);

    await useCases.updateAlarm(
      _alarm(enabled: false, nextScheduledAt: null),
    );

    expect(scheduler.canceled, [1]);
    expect(scheduler.scheduled, isEmpty);
  });

  test('delete success cancels scheduled alarm', () async {
    final scheduler = _FakeAlarmRingerService();
    final repo = AlarmRepositoryImpl(_FakeAlarmLocalDataSource());
    final useCases = AlarmUseCases(repo, scheduler: scheduler);

    await useCases.deleteAlarm(1);

    expect(scheduler.canceled, [1]);
  });

  test('repository failure does not change scheduled alarms', () async {
    final scheduler = _FakeAlarmRingerService();
    final repo = AlarmRepositoryImpl(
      _FakeAlarmLocalDataSource(
        saveResult: Result.failure(Failure.database(message: 'nope')),
        updateResult: Result.failure(Failure.database(message: 'nope')),
        deleteResult: Result.failure(Failure.database(message: 'nope')),
      ),
    );
    final useCases = AlarmUseCases(repo, scheduler: scheduler);

    await useCases.saveAlarm(_alarm(id: null));
    await useCases.updateAlarm(_alarm());
    await useCases.deleteAlarm(1);

    expect(scheduler.canceled, isEmpty);
    expect(scheduler.scheduled, isEmpty);
  });
}
