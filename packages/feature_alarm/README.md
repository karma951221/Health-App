# feature_alarm

알람 기능의 도메인 로직, 데이터 계층, 프레젠테이션 BLoC를 담당하는 Flutter 패키지.

---

## 책임 범위

- 알람 CRUD (저장 / 수정 / 삭제 / 토글)
- 다음 울림 시각 계산 (1회성 / 요일 반복)
- OS 알람 스케줄 동기화 (예약 / 취소 / reconcile)
- 알람 목록 및 편집 BLoC

---

## 아키텍처

클린 아키텍처 3계층으로 구성되며, 바깥 계층이 안쪽 계층에만 의존한다.

```
presentation/   ← BLoC (AlarmListBloc, AlarmEditCubit)
    │
domain/         ← 엔티티, 유스케이스, 인터페이스
    │
data/           ← Repository 구현, AlarmRingerServiceImpl, 매퍼
```

### 핵심 불변식

> **drift가 유일한 진실(source of truth)이다.**  
> `alarm` 패키지(OS 스케줄러)는 drift의 투영(projection)일 뿐이며, 목록을 alarm 패키지에서 읽지 않는다.

- 알람 목록은 항상 drift 스트림(`watchAlarms()`)에서 구독한다.
- OS 예약 상태는 `AlarmRingerService.syncFromStore()`로만 drift와 동기화한다.
- 울림 화면에 필요한 상세(hour/minute/label/shakeCount)는 울림 시점에 drift에서 조회한다.

---

## 디렉터리 구조

```
lib/
├── feature_alarm.dart          # 퍼블릭 배럴 파일 (공개 API)
└── src/
    ├── domain/
    │   ├── entities/
    │   │   ├── alarm.dart                      # Alarm 엔티티
    │   │   └── alarm_notification_payload.dart # 울림 이벤트 payload (alarmId만 포함)
    │   ├── extensions/
    │   │   ├── alarm_extensions.dart           # nextOccurrence / withNextSchedule
    │   │   └── alarm_payload_extensions.dart   # JSON 직렬화 / 역직렬화 헬퍼
    │   ├── repositories/
    │   │   └── alarm_repository.dart           # AlarmRepository 인터페이스
    │   ├── schedulers/
    │   │   └── alarm_ringer_service.dart       # AlarmRingerService 인터페이스
    │   └── usecases/
    │       ├── alarm_usecases.dart             # 유스케이스 파사드
    │       ├── alarm_management/               # save / update / delete / toggle
    │       └── alarm_monitoring/               # watchAlarms
    ├── data/
    │   ├── mappers/
    │   │   └── alarm_mapper.dart               # AlarmTableData ↔ Alarm 변환
    │   ├── repositories/
    │   │   └── alarm_repository_impl.dart      # AlarmRepository 구현
    │   └── schedulers/
    │       ├── alarm_ringer_service_impl.dart  # AlarmRingerService 구현
    │       └── alarm_settings_mapper.dart      # Alarm → AlarmSettings 변환 (extension)
    └── presentation/
        └── bloc/
            ├── alarm_list/   # AlarmListBloc (목록 조회 / 토글 / 삭제)
            └── alarm_edit/   # AlarmEditCubit (신규 생성 / 기존 편집 / 저장)
```

---

## 주요 컴포넌트

### `Alarm` 엔티티

```dart
Alarm({
  int? id,             // null이면 아직 DB에 저장되지 않은 신규 알람
  required int hour,
  required int minute,
  required int weekdayMask,   // 비트 마스크: bit0=월, bit1=화, … bit6=일. 0이면 1회성.
  DateTime? oneShotDate,
  DateTime? nextScheduledAt,  // null이면 비활성 상태 (OS에 예약 안 됨)
  required bool enabled,
  required int shakeCount,
  required String label,
})
```

`weekdayMask == 0`이면 1회성 알람, 0이 아니면 반복 알람이다.

### `AlarmRingerService` 인터페이스

OS 알람 패키지(`alarm`)를 추상화한다. **구현체(`AlarmRingerServiceImpl`)는 퍼블릭 API에 노출되지 않는다.**

| 메서드 | 설명 |
|--------|------|
| `scheduleAlarm(alarm)` | 단일 알람을 OS에 예약 |
| `cancelAlarm(alarmId)` | OS에서 알람 취소 |
| `syncFromStore(alarms)` | drift 스냅샷으로 OS 예약 상태를 reconcile |
| `listenForRinging(onRing)` | 알람 울림 이벤트 구독 |
| `stop(alarmId)` | 현재 울리는 알람 정지 |

#### `syncFromStore` reconcile 규칙

앱 시작(cold start) 시 drift 전체 목록과 OS 현재 예약 목록을 비교해 일치시킨다.

1. **원하는 집합**: `enabled && id != null && nextScheduledAt != null`인 알람
2. OS에 있으나 원하는 집합에 없는 항목(고아) → `Alarm.stop()` 취소
3. 원하는 집합에 있으나 OS에 없거나 `dateTime`이 다른 항목 → `scheduleAlarm()` 예약
4. 이미 올바르게 예약된 항목 → **건드리지 않음** (cold-start 중 울리는 알람 보호)

### `AlarmUseCases` 파사드

```dart
AlarmUseCases(repository, scheduler: ringer)

useCases.watchAlarms()       // Stream<List<Alarm>>
useCases.saveAlarm(alarm)    // nextScheduledAt 계산 후 저장 + OS 예약
useCases.updateAlarm(alarm)  // nextScheduledAt 재계산 후 수정 + OS 재예약
useCases.deleteAlarm(id)     // DB 삭제 + OS 취소
useCases.toggleAlarm(alarm: a, enabled: bool) // 활성화/비활성화
```

`saveAlarm` / `updateAlarm` / `toggleAlarm`은 모두 `nextScheduledAt`을 자동 계산한다.

### `AlarmSettingsExtension` (alarm_settings_mapper.dart)

`Alarm` → `alarm` 패키지의 `AlarmSettings` 변환 extension.  
payload에는 `alarmId`만 포함한다. 알람 상세(label/shakeCount)는 OS 알림 text에만 쓰이고 payload에는 저장하지 않는다.

```dart
alarm.toSettings(audioPath: '...')  // AlarmSettings 반환
```

### BLoC

| 클래스 | 역할 |
|--------|------|
| `AlarmListBloc` | 알람 목록 구독 (`watchAlarms()` 스트림), 토글/삭제 처리 |
| `AlarmEditCubit` | 알람 생성/편집 폼 상태 관리, 저장(`save()`) 처리 |

---

## 데이터 흐름

### 울림 흐름

```
OS 알람 울림
    │
    ▼
AlarmRingerServiceImpl (listenForRinging)
    │  payload: { alarmId }
    ▼
dependency_injection._handleRing
    │  drift에서 alarmId로 알람 조회
    ▼
AlarmRingingScreen(hour, minute, label, shakeTarget)
    │  사용자가 해제
    ▼
_dismiss(alarmId)
    │
    ├─ 반복 알람 (weekdayMask != 0) → updateAlarm (다음 회차 재예약)
    └─ 1회성 알람 (weekdayMask == 0) → toggleAlarm(enabled: false) (소진)
```

### 부팅 흐름

```
앱 시작
    │
    ▼
Alarm.init()          ← alarm 패키지 초기화 (필수 호출)
    │
    ▼
_bootstrap()
    │  drift에서 전체 알람 조회
    ▼
AlarmRingerService.syncFromStore(alarms)
    │  reconcile: 고아 취소 + 누락/변경분만 예약
    ▼
OS 예약 상태 = drift 상태
```

---

## 개발 가이드

### 코드 생성 (freezed / json_serializable)

엔티티 파일(`Alarm`, `AlarmNotificationPayload`)을 수정하면 반드시 재생성:

```bash
cd packages/feature_alarm
dart run build_runner build --delete-conflicting-outputs
```

생성된 `*.freezed.dart` / `*.g.dart`는 `.gitignore`에 등록되어 있으므로 커밋하지 않는다.

### 테스트 실행

```bash
cd packages/feature_alarm
flutter test
```

### 커스텀 알람음 추가 (TODO)

`AlarmRingerServiceImpl`에 `audioPath` 파라미터가 준비되어 있다.
`main.dart`에서 `AlarmRingerServiceImpl(audioPath: 'assets/audio/alarm.mp3')`로 주입하면 된다.
현재 `null`이면 기기 기본 알람음으로 울린다.

---

## 퍼블릭 API (`feature_alarm.dart`)

impl 파일은 배럴에서 제외되어 있다. 앱 계층에서 impl을 직접 import해야 할 경우 `src/` 경로를 명시적으로 import한다.

```dart
// 퍼블릭 (권장)
import 'package:feature_alarm/feature_alarm.dart';

// 앱 DI 계층 전용 (AlarmRingerServiceImpl, AlarmRepositoryImpl)
import 'package:feature_alarm/src/data/schedulers/alarm_ringer_service_impl.dart';
import 'package:feature_alarm/src/data/repositories/alarm_repository_impl.dart';
```
