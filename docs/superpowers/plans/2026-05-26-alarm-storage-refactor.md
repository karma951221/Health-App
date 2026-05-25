# Alarm Storage Refactoring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** drift를 유일한 관리 대상으로, alarm 패키지를 순수 투영으로 만들어 3가지 틈(고아 항목 미정리 / payload 중복 / 인터페이스 불명확)을 메운다.

**Architecture:** `AlarmRingerService` 인터페이스의 `rescheduleAll`을 reconcile 의미를 가진 `syncFromStore`로 교체하고, `AlarmNotificationPayload`를 `alarmId` 단일 필드로 축소. `_handleRing`은 울림 시점에 drift에서 알람 상세를 조회하여 화면에 전달.

**Tech Stack:** Flutter/Dart, alarm package (v5.4.0), drift/SQLite, freezed, json_serializable, BLoC

**Spec:** `docs/superpowers/specs/2026-05-26-alarm-storage-refactor-design.md`

---

## 변경 파일 목록

| 파일 | 변경 내용 |
|------|-----------|
| `packages/feature_alarm/lib/src/domain/schedulers/alarm_ringer_service.dart` | `rescheduleAll` → `syncFromStore` 시그니처 교체 + 불변식 주석 |
| `packages/feature_alarm/lib/src/data/schedulers/alarm_ringer_service_impl.dart` | `syncFromStore` reconcile 구현, `rescheduleAll` 제거 |
| `packages/feature_alarm/lib/src/domain/entities/alarm_notification_payload.dart` | 필드 축소: `alarmId`만 남김 |
| `packages/feature_alarm/lib/src/domain/entities/alarm_notification_payload.freezed.dart` | build_runner 재생성 |
| `packages/feature_alarm/lib/src/domain/entities/alarm_notification_payload.g.dart` | build_runner 재생성 |
| `packages/feature_alarm/lib/src/data/schedulers/alarm_settings_mapper.dart` | payload에 `alarmId`만 인코딩 |
| `packages/feature_alarm/lib/src/domain/extensions/alarm_payload_extensions.dart` | `toAlarmPayload()` 단순화 |
| `lib/core/dependency_injection/dependency_injection.dart` | `_bootstrap`: `syncFromStore` 호출; `_handleRing`: drift 조회로 교체 |
| `packages/feature_alarm/test/data/schedulers/alarm_ringer_service_impl_test.dart` | payload 검증을 `alarmId`만으로 수정 |
| `packages/feature_alarm/test/domain/usecases/alarm_schedule_update_test.dart` | `_FakeAlarmRingerService`: `rescheduleAll` → `syncFromStore` |
| `test/core/notifications/alarm_usecases_test.dart` | `_FakeAlarmRingerService`: `rescheduleAll` → `syncFromStore` |

---

## Task 1: 인터페이스 교체 및 테스트 fake 업데이트

두 테스트 파일의 `_FakeAlarmRingerService`와 인터페이스를 함께 수정한다.
`rescheduleAll`이 사라지기 전에 테스트 fake를 먼저 업데이트하면 컴파일 에러가 발생한다.
인터페이스와 fake를 같은 커밋에서 바꾼다.

**Files:**
- Modify: `packages/feature_alarm/lib/src/domain/schedulers/alarm_ringer_service.dart`
- Modify: `packages/feature_alarm/test/domain/usecases/alarm_schedule_update_test.dart`
- Modify: `test/core/notifications/alarm_usecases_test.dart`

- [ ] **Step 1: `AlarmRingerService` 인터페이스 수정**

`packages/feature_alarm/lib/src/domain/schedulers/alarm_ringer_service.dart` 전체를 아래로 교체:

```dart
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
```

- [ ] **Step 2: `alarm_schedule_update_test.dart`의 fake 업데이트**

`packages/feature_alarm/test/domain/usecases/alarm_schedule_update_test.dart`의 `_FakeAlarmRingerService`에서
`rescheduleAll` → `syncFromStore`로 변경:

```dart
class _FakeAlarmRingerService implements AlarmRingerService {
  final List<Alarm> scheduled = [];

  @override
  Future<void> cancelAlarm(int alarmId) async {}

  @override
  Future<void> syncFromStore(List<Alarm> alarms) async {}  // ← 변경

  @override
  Future<void> scheduleAlarm(Alarm alarm) async {
    scheduled.add(alarm);
  }

  @override
  void listenForRinging(void Function(AlarmNotificationPayload payload) onRing) {}

  @override
  Future<void> stop(int alarmId) async {}
}
```

- [ ] **Step 3: `alarm_usecases_test.dart`의 fake 업데이트**

`test/core/notifications/alarm_usecases_test.dart`의 `_FakeAlarmRingerService`에서
`rescheduleAll` → `syncFromStore`로 변경:

```dart
class _FakeAlarmRingerService implements AlarmRingerService {
  final scheduled = <Alarm>[];
  final canceled = <int>[];
  final synced = <List<Alarm>>[];  // rescheduled → synced

  @override
  Future<void> cancelAlarm(int alarmId) async {
    canceled.add(alarmId);
  }

  @override
  Future<void> syncFromStore(List<Alarm> alarms) async {  // ← 변경
    synced.add(alarms);
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
```

- [ ] **Step 4: 테스트 실행으로 컴파일 확인**

```bash
cd /Users/no/Desktop/health-app
flutter test packages/feature_alarm/test/domain/usecases/alarm_schedule_update_test.dart test/core/notifications/alarm_usecases_test.dart
```

Expected: 모든 테스트 PASS (fake가 인터페이스와 일치하므로 컴파일 성공)

- [ ] **Step 5: 커밋**

```bash
git add packages/feature_alarm/lib/src/domain/schedulers/alarm_ringer_service.dart \
        packages/feature_alarm/test/domain/usecases/alarm_schedule_update_test.dart \
        test/core/notifications/alarm_usecases_test.dart
git commit -m "refactor(alarm): replace rescheduleAll with syncFromStore interface"
```

---

## Task 2: `AlarmRingerServiceImpl.syncFromStore` 구현

`rescheduleAll` 제거, `syncFromStore` reconcile 로직 구현.

**Files:**
- Modify: `packages/feature_alarm/lib/src/data/schedulers/alarm_ringer_service_impl.dart`

- [ ] **Step 1: `AlarmRingerServiceImpl` 업데이트**

`packages/feature_alarm/lib/src/data/schedulers/alarm_ringer_service_impl.dart` 전체를 아래로 교체:

```dart
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
```

- [ ] **Step 2: feature_alarm 패키지 분석 빌드 통과 확인**

```bash
cd /Users/no/Desktop/health-app
flutter analyze packages/feature_alarm/lib/src/data/schedulers/alarm_ringer_service_impl.dart
```

Expected: No issues found.

- [ ] **Step 3: 전체 패키지 테스트 실행**

```bash
cd /Users/no/Desktop/health-app
flutter test packages/feature_alarm/
```

Expected: All tests pass.

- [ ] **Step 4: 커밋**

```bash
git add packages/feature_alarm/lib/src/data/schedulers/alarm_ringer_service_impl.dart
git commit -m "feat(alarm): implement syncFromStore with orphan cleanup and reconcile"
```

---

## Task 3: `AlarmNotificationPayload` 축소 + 관련 코드 업데이트

payload를 `alarmId`만 남기고, 이에 의존하는 mapper/extension/test를 함께 수정.
freezed + json_serializable 코드를 재생성해야 하므로 build_runner를 실행한다.

**Files:**
- Modify: `packages/feature_alarm/lib/src/domain/entities/alarm_notification_payload.dart`
- Regenerate: `packages/feature_alarm/lib/src/domain/entities/alarm_notification_payload.freezed.dart`
- Regenerate: `packages/feature_alarm/lib/src/domain/entities/alarm_notification_payload.g.dart`
- Modify: `packages/feature_alarm/lib/src/data/schedulers/alarm_settings_mapper.dart`
- Modify: `packages/feature_alarm/lib/src/domain/extensions/alarm_payload_extensions.dart`
- Modify: `packages/feature_alarm/test/data/schedulers/alarm_ringer_service_impl_test.dart`

- [ ] **Step 1: 매퍼 테스트를 먼저 업데이트 (TDD — 아직 실패해야 함)**

`packages/feature_alarm/test/data/schedulers/alarm_ringer_service_impl_test.dart`의
`'encodes ring-screen data into the payload'` 테스트를 아래처럼 수정한다.
(hour/minute/label/shakeCount 검증 제거, alarmId만 남김):

```dart
test('encodes ring-screen data into the payload', () {
  final settings = _alarm(id: 7, hour: 6, minute: 30, label: '아침', shakeCount: 25).toSettings();

  final payload = settings.payload?.toAlarmPayload();
  expect(payload?.alarmId, 7);
});
```

- [ ] **Step 2: 테스트 실행 — 현재 상태에서 PASS 확인 (alarmId 검증은 이미 작동함)**

```bash
cd /Users/no/Desktop/health-app
flutter test packages/feature_alarm/test/data/schedulers/alarm_ringer_service_impl_test.dart
```

Expected: All 4 tests PASS (변경 전이므로 alarmId 검증은 이미 통과).

- [ ] **Step 3: `AlarmNotificationPayload` 엔티티 축소**

`packages/feature_alarm/lib/src/domain/entities/alarm_notification_payload.dart` 전체를 아래로 교체:

```dart
import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'alarm_notification_payload.freezed.dart';
part 'alarm_notification_payload.g.dart';

@freezed
@JsonSerializable()
class AlarmNotificationPayload with _$AlarmNotificationPayload {
  const AlarmNotificationPayload({
    required this.alarmId,
  });

  final int alarmId;

  factory AlarmNotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$AlarmNotificationPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$AlarmNotificationPayloadToJson(this);

  static const type = 'alarm';
}
```

- [ ] **Step 4: `alarm_settings_mapper.dart` payload 인코딩 축소**

`packages/feature_alarm/lib/src/data/schedulers/alarm_settings_mapper.dart` 내
`toSettings` 메서드의 payload 생성 부분만 아래처럼 교체:

이전:
```dart
    final payload = AlarmNotificationPayload(
      alarmId: id!,
      hour: hour,
      minute: minute,
      label: label,
      shakeCount: shakeCount,
    );
```

이후:
```dart
    final payload = AlarmNotificationPayload(alarmId: id!);
```

전체 파일 최종본:

```dart
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

    final payload = AlarmNotificationPayload(alarmId: id!);

    return alarm_pkg.AlarmSettings(
      id: id!,
      dateTime: nextScheduledAt!,
      // TODO(custom-sound): 커스텀 알람음 설정 기능 구현 시 audioPath를 채운다.
      assetAudioPath: audioPath,
      loopAudio: true,
      vibrate: true,
      androidFullScreenIntent: true,
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
```

- [ ] **Step 5: `alarm_payload_extensions.dart` 단순화**

`packages/feature_alarm/lib/src/domain/extensions/alarm_payload_extensions.dart` 전체를 아래로 교체:

```dart
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
```

(변경 없음 — `toAlarmPayload`는 `fromJson`에 위임하므로 엔티티 필드 변경과 무관하게 동작)

- [ ] **Step 6: build_runner로 freezed/json 코드 재생성**

```bash
cd /Users/no/Desktop/health-app
dart run build_runner build --delete-conflicting-outputs
```

Expected: 완료 메시지 출력, `alarm_notification_payload.freezed.dart`와 `alarm_notification_payload.g.dart` 재생성됨.

- [ ] **Step 7: 테스트 실행**

```bash
cd /Users/no/Desktop/health-app
flutter test packages/feature_alarm/
```

Expected: All tests pass.
payload 검증이 `alarmId`만 남아 있으므로 `'encodes ring-screen data into the payload'` 테스트 PASS.

- [ ] **Step 8: 커밋**

```bash
git add packages/feature_alarm/lib/src/domain/entities/alarm_notification_payload.dart \
        packages/feature_alarm/lib/src/domain/entities/alarm_notification_payload.freezed.dart \
        packages/feature_alarm/lib/src/domain/entities/alarm_notification_payload.g.dart \
        packages/feature_alarm/lib/src/data/schedulers/alarm_settings_mapper.dart \
        packages/feature_alarm/lib/src/domain/extensions/alarm_payload_extensions.dart \
        packages/feature_alarm/test/data/schedulers/alarm_ringer_service_impl_test.dart
git commit -m "refactor(alarm): reduce AlarmNotificationPayload to alarmId only"
```

---

## Task 4: `dependency_injection.dart` 업데이트

`_bootstrap`이 `syncFromStore`를 호출하고,
`_handleRing`이 drift에서 알람 상세를 조회해 화면에 전달하도록 수정.

**Files:**
- Modify: `lib/core/dependency_injection/dependency_injection.dart`

- [ ] **Step 1: `_bootstrap` 호출 변경**

`lib/core/dependency_injection/dependency_injection.dart`의 `_bootstrap` 메서드에서
`ringer.rescheduleAll(alarms)` → `ringer.syncFromStore(alarms)`로 변경:

```dart
Future<void> _bootstrap() async {
  await _requestPermissions();

  final useCases = context.read<AlarmUseCases>();
  final ringer = context.read<AlarmRingerService>();
  final alarms = await useCases.watchAlarms().first;
  await ringer.syncFromStore(alarms);  // ← rescheduleAll → syncFromStore
}
```

- [ ] **Step 2: `_handleRing` 비동기 drift 조회로 교체**

`lib/core/dependency_injection/dependency_injection.dart`의
`_handleRing` 메서드를 아래로 교체:

```dart
void _handleRing(AlarmNotificationPayload payload) {
  _handleRingAsync(payload); // intentionally not awaited
}

Future<void> _handleRingAsync(AlarmNotificationPayload payload) async {
  final useCases = context.read<AlarmUseCases>();
  final alarms = await useCases.watchAlarms().first;

  Alarm? match;
  for (final a in alarms) {
    if (a.id == payload.alarmId) {
      match = a;
      break;
    }
  }
  // 삭제된 알람이 울리는 경쟁 상황 — 안전하게 무시
  if (match == null) return;

  // closure 내에서도 non-nullable로 사용하기 위한 로컬 변수
  final alarm = match;

  final navigator = appNavigatorKey.currentState;
  if (navigator == null) return;

  navigator.push(
    MaterialPageRoute<void>(
      builder: (_) => AlarmRingingScreen(
        alarmId: alarm.id,
        hour: alarm.hour,
        minute: alarm.minute,
        label: alarm.label,
        shakeTarget: alarm.shakeCount,
        onDismiss: () => _dismiss(payload.alarmId),
      ),
    ),
  );
}
```

- [ ] **Step 3: 전체 앱 분석 통과 확인**

```bash
cd /Users/no/Desktop/health-app
flutter analyze lib/core/dependency_injection/dependency_injection.dart
```

Expected: No issues found.

- [ ] **Step 4: 전체 테스트 실행**

```bash
cd /Users/no/Desktop/health-app
flutter test
```

Expected: All tests pass.

- [ ] **Step 5: 커밋**

```bash
git add lib/core/dependency_injection/dependency_injection.dart
git commit -m "feat(alarm): _bootstrap uses syncFromStore; _handleRing queries drift on ring"
```

---

## 수동 검증 시나리오

코드 변경 후 실기기(또는 에뮬레이터)에서 아래 시나리오를 확인한다:

1. **켜진 반복 알람 재예약**: 앱 강제 종료 후 재시작 → 켜진 알람만 OS에 재예약됨
2. **꺼진 알람 보관**: 비활성화된 알람이 OS에 예약되지 않음 (고아 취소 포함)
3. **울림 → 해제 → 다음 회차**: 반복 알람 울림, 해제, 다음 요일로 재예약됨
4. **1회성 알람 소진**: 비반복 알람 해제 후 비활성화 상태로 목록에 잔류

