# 알람 저장 구조 리팩터링 설계

날짜: 2026-05-26
대상 패키지: `feature_alarm`, `infra_local_db`, 앱 `lib/`

## 배경 / 문제

알람 정보가 두 곳에 저장된다고 느껴졌다.

- **drift / SQLite (`infra_local_db`)**: 앱의 알람 목록. `hour, minute, weekdayMask, oneShotDate, nextScheduledAt, enabled, shakeCount, label` 전부 보관. meal/workout 테이블과 같은 DB 공유.
- **`alarm` 패키지 (SharedPreferences)**: `AlarmSettings`를 내부 저장. `Alarm.set()`이 항상 "prefs 저장 + 네이티브 예약"을 한 묶음으로 수행하며, 이 저장은 끌 수 없다.

요구사항상 **꺼진 알람 보관**과 **반복 요일 알람**이 모두 필수다. 이 때문에:

- alarm 패키지 단독 저장은 불가능하다. `AlarmSettings`에는 `weekdayMask/enabled/oneShotDate` 필드가 없고(오직 `payload` String), 꺼진 알람은 "저장=예약=울림"이라 안 울리게 보관할 방법이 없다.
- 따라서 자체 저장소(drift)는 유지해야 한다.

## 핵심 발견

현재 앱은 **이미 길 1(= drift가 유일한 진실, alarm 패키지는 파생물) 구조로 동작 중**이다.

- 부팅 시 `dependency_injection.dart`의 `_bootstrap`이 drift에서 알람을 읽어 `rescheduleAll`로 OS에 재예약한다.
- 울림 해제 시 `_dismiss`가 drift에서 조회 후 반복 알람은 `updateAlarm`로 다음 회차 재예약, 1회성은 `toggleAlarm(false)`로 소진한다.
- 목록은 BLoC가 `watchAlarms()`(drift 스트림)만 구독한다. alarm 패키지에서 목록을 읽지 않는다.

"두 개가 동시에 관리된다"는 인상은 다음 **3가지 틈** 때문이다.

1. `main.dart`의 `Alarm.init()`이 alarm 패키지 자기 prefs를 복원 → alarm 패키지도 "저장소"처럼 보임. (`init()`은 패키지 필수 호출이라 제거 불가)
2. `rescheduleAll`이 고아 항목을 청소하지 않음 → drift엔 없는데 alarm 패키지엔 남은 항목이 정리되지 않아 두 저장소가 어긋날 수 있는 유일한 경로.
3. `payload`가 drift 컬럼(hour/minute/label/shakeCount)을 중복 저장 → "데이터가 두 번 저장된다"는 직접적 인상.

## 목표

큰 재작성 없이, 위 3가지 틈을 메워 **"drift = 유일한 관리 대상, alarm 패키지 = drift의 순수 투영"** 불변식을 명시적이고 어긋날 수 없게 만든다.

비목표: 저장소를 물리적으로 1개로 합치기(불가능), drift 제거, meal/workout 저장 방식 변경.

## 설계

### 변경 1+2 — `syncFromStore` (청소 후 재구성) + 불변식 문서화

`AlarmRingerService` 도메인 인터페이스에서 기존 `rescheduleAll(List<Alarm>)`을 `syncFromStore(List<Alarm>)`로 대체한다. 부팅 재조정의 유일한 진입점이 된다.

**의미(reconciliation):** OS 예약 상태를 store(drift)와 일치시킨다.

- store가 원하는 알람 = `enabled && nextScheduledAt != null`인 알람.
- OS에 예약됐지만 store가 원하지 않는 항목(고아) → `Alarm.stop(id)`로 취소.
- store가 원하지만 OS에 없거나 `dateTime`이 다른 항목 → `scheduleAlarm`로 예약.
- 이미 올바르게 예약된 항목(같은 id, 같은 시각) → 건드리지 않는다.

마지막 규칙이 중요한 이유: `Alarm.set()`은 같은 id를 재설정할 때 기존(울리는 중일 수 있는) 알람을 먼저 stop한다. 부팅이 알람 울림에서 비롯된 콜드 스타트일 때 정당하게 울리는 알람을 끊지 않도록, 이미 맞게 걸린 알람은 재설정하지 않는다.

```dart
// AlarmRingerServiceImpl
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
    final existing =
        scheduled.where((s) => s.id == alarm.id).firstOrNull;
    if (existing == null || existing.dateTime != alarm.nextScheduledAt) {
      await scheduleAlarm(alarm);
    }
  }
}
```

`_bootstrap`은 `rescheduleAll(alarms)` 대신 `syncFromStore(alarms)`를 호출한다.

불변식을 `AlarmRingerService` 인터페이스와 `AlarmRingerServiceImpl` 상단 주석으로 명시한다: "drift가 유일한 진실. 이 서비스는 drift의 알람을 OS 스케줄로 투영할 뿐이며, 목록을 alarm 패키지에서 읽지 않는다."

### 변경 3 — `payload`를 `alarmId`만 남기고 축소 (Approach B)

`AlarmNotificationPayload`를 `alarmId` 단일 필드로 축소한다. 울림에 필요한 상세(hour/minute/label/shakeCount)는 울림 시점에 drift에서 조회한다.

- **엔티티**: `AlarmNotificationPayload { alarmId }`. `toJson/fromJson` 유지. (`type` 상수는 사용처 확인 후 유지/제거 — 구현 단계에서 결정)
- **`alarm_settings_mapper.toSettings`**: payload에 `alarmId`만 인코딩. `notificationSettings`의 title/body는 예약 시점의 `Alarm.label`/`shakeCount`를 그대로 사용(변경 없음).
- **`_handleRing(payload)`**: 기존 `_dismiss`와 동일 패턴으로 `await useCases.watchAlarms().first`에서 `payload.alarmId`로 알람을 찾아 hour/minute/label/shakeCount를 `AlarmRingingScreen`에 전달. 못 찾으면(삭제된 알람이 울린 경우) 안전하게 무시하거나 기본값 표시.
  - 새 repository/usecase 메서드를 추가하지 않고 기존 `watchAlarms().first`를 재사용한다(알람 수가 적고 `_dismiss`가 이미 같은 패턴 사용).
- 결과: hour/minute/label/shakeCount가 drift 한 곳에만 존재.

## 영향 받는 파일

- `packages/feature_alarm/lib/src/domain/schedulers/alarm_ringer_service.dart` — `rescheduleAll` → `syncFromStore` 시그니처 변경 + 불변식 주석.
- `packages/feature_alarm/lib/src/data/schedulers/alarm_ringer_service_impl.dart` — `syncFromStore` 구현, 불변식 주석.
- `packages/feature_alarm/lib/src/domain/entities/alarm_notification_payload.dart` — 필드 축소(+ freezed/json 재생성).
- `packages/feature_alarm/lib/src/data/schedulers/alarm_settings_mapper.dart` — payload 인코딩 축소.
- `lib/core/dependency_injection/dependency_injection.dart` — `_bootstrap`에서 `syncFromStore` 호출, `_handleRing`에서 drift 조회.
- 테스트:
  - `alarm_ringer_service_impl_test.dart` — payload 검증을 alarmId만으로 수정.
  - `alarm_schedule_update_test.dart` 내 `_FakeAlarmRingerService` — `rescheduleAll` → `syncFromStore`로 시그니처 변경.
  - (추가 권장) `syncFromStore`의 reconcile 동작(고아 취소 / 변경분만 예약 / 정상 항목 미변경) 단위 테스트.

## 테스트 전략

- `syncFromStore`: fake `Alarm` static을 직접 검증하기 어렵다. `AlarmRingerService`를 인터페이스로 두고, reconcile 로직을 순수 함수(원하는 set vs 현재 set → 취소/예약 목록 계산)로 분리해 단위 테스트하는 방안을 구현 단계에서 검토. 분리 비용이 크면 도메인 레벨에서 호출 횟수 검증으로 대체.
- payload 축소: 기존 매퍼 테스트를 alarmId 검증으로 수정. 울림 화면 조회 흐름은 위젯/통합 테스트 범위 밖이면 수동 확인으로 남긴다.
- 회귀: 반복 알람 1회 울림→해제→다음 회차 재예약, 꺼진 알람 보관, 부팅 후 켜진 알람만 재예약을 수동 시나리오로 확인.

## 위험 / 주의

- `syncFromStore`의 "정상 항목 미변경" 규칙을 빠뜨리면 콜드 스타트 시 울리는 알람을 끊을 수 있다. reconcile 비교를 반드시 포함.
- payload 축소 후 삭제된 알람이 울리는 경쟁 상황(조회 실패)을 graceful하게 처리.
- `oneShotDate`는 현재 엔티티에 있으나 사용 흐름이 옅다 — 이번 범위에서 동작 변경 없음, 기존 동작 유지.
