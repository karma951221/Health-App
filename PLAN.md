# Health App — 설계 문서

> 일일 운동·식단 기록 + 미라클 모닝 알람 (흔들어서 해제)

---

## 핵심 목적

- 하루하루 운동·식단을 **마찰 없이 기록** (복잡한 입력 없음)
- **흔들어야만 꺼지는 알람**으로 기상 습관 강제
- 개인용 MVP — 인증·서버 없이 디바이스 로컬 저장

---

## 기술 스택

| 역할 | 패키지 |
|---|---|
| 플랫폼 | Flutter (iOS + Android 단일 코드베이스) |
| 상태 관리 | `flutter_bloc` (Cubit / Bloc) |
| 의존성 주입 | `get_it` + `injectable` |
| DB | `drift` (타입 안전 SQLite) |
| 알림·알람 | `flutter_local_notifications` |
| Android 알람 | `android_alarm_manager_plus` |
| 사진 | `image_picker` + `path_provider` |
| 흔들기 감지 | `sensors_plus` |
| 달력 | `table_calendar` |
| E2E 테스트 | `patrol` |

---

## 프로젝트 구조

```
lib/
├── main.dart                          # await configureDependencies() → runApp
├── app.dart                           # MaterialApp + BottomNavigationBar
├── di/
│   ├── injection.dart                 # @InjectableInit
│   └── injection.config.dart          # build_runner 생성
├── core/
│   ├── db/
│   │   ├── database.dart              # @singleton (AppDatabase)
│   │   └── tables/
│   │       ├── workouts.dart
│   │       ├── meals.dart
│   │       └── alarms.dart
│   ├── notifications/
│   │   └── notification_service.dart  # @lazySingleton
│   ├── storage/
│   │   └── photo_storage.dart         # @lazySingleton
│   └── theme/theme.dart
├── features/
│   ├── workout/
│   │   ├── data/workout_repository.dart   # @lazySingleton
│   │   ├── bloc/
│   │   │   ├── workout_cubit.dart         # @injectable
│   │   │   └── workout_state.dart
│   │   └── ui/
│   │       ├── workout_tab.dart
│   │       └── workout_entry_sheet.dart
│   ├── meal/
│   │   ├── data/meal_repository.dart
│   │   ├── bloc/
│   │   │   ├── meal_cubit.dart
│   │   │   └── meal_state.dart
│   │   └── ui/
│   │       ├── meal_tab.dart
│   │       └── meal_entry_sheet.dart
│   └── alarm/
│       ├── data/alarm_repository.dart
│       ├── alarm_scheduler.dart           # OS별 추상화 @lazySingleton
│       ├── shake_detector.dart
│       ├── bloc/
│       │   ├── alarm_list_cubit.dart      # @injectable
│       │   ├── alarm_list_state.dart
│       │   ├── alarm_ringing_bloc.dart    # @injectable (센서 스트림 처리)
│       │   └── alarm_ringing_state.dart
│       └── ui/
│           ├── alarm_tab.dart
│           ├── alarm_edit_sheet.dart
│           └── alarm_ringing_screen.dart
└── shared/widgets/
    ├── date_header.dart
    └── empty_state.dart
```

---

## 데이터 모델

```dart
// 운동 기록
class Workouts extends Table {
  IntColumn      get id       => integer().autoIncrement()();
  DateTimeColumn get loggedAt => dateTime()();
  TextColumn     get memo     => text()();
}

// 식단 기록
class Meals extends Table {
  IntColumn      get id        => integer().autoIncrement()();
  DateTimeColumn get loggedAt  => dateTime()();
  TextColumn     get memo      => text()();
  TextColumn     get photoPath => text().nullable()();  // 파일명만 (앱 docs/meals/)
}

// 알람
class Alarms extends Table {
  IntColumn      get id              => integer().autoIncrement()();
  IntColumn      get hour            => integer()();
  IntColumn      get minute          => integer()();
  IntColumn      get weekdayMask     => integer()();  // 7비트 (월=bit0 … 일=bit6), 0=일회성
  DateTimeColumn get oneShotDate     => dateTime().nullable()(); // 일회성 알람 날짜
  DateTimeColumn get nextScheduledAt => dateTime().nullable()(); // 디버깅·재예약용
  BoolColumn     get enabled         => boolean().withDefault(const Constant(true))();
  IntColumn      get shakeCount      => integer().withDefault(const Constant(20))();
  TextColumn     get label           => text().withDefault(const Constant('미라클 모닝'))();
}
```

---

## 상태관리 / DI 규약

### Cubit vs Bloc 선택
- **Cubit** — 단순 CRUD·로딩/성공/실패 (운동 목록, 식단 목록, 알람 목록)
- **Bloc** — 외부 스트림 이벤트 시퀀스 처리 (알람 울림 화면 ← 가속도계 스트림)

### DI 어노테이션
| 어노테이션 | 사용 대상 | 수명 |
|---|---|---|
| `@singleton` | `AppDatabase` | 앱 전체 1개 |
| `@lazySingleton` | Repository, Scheduler, Service | 앱 전체 1개 (첫 호출 시 생성) |
| `@injectable` | Cubit / Bloc | 화면 진입 시마다 새 인스턴스 |

### UI 주입 패턴
```dart
BlocProvider(
  create: (_) => getIt<WorkoutCubit>(),
  child: const WorkoutTab(),
)
```

---

## 화면 흐름

### 하단 탭 3개: 운동 | 식단 | 알람

**운동 탭**
- 날짜 헤더 (오늘 기본, 달력 아이콘으로 날짜 이동)
- 기록 리스트 (시각 + 메모)
- FAB → BottomSheet: 텍스트 입력 + 저장
- 항목 길게 누름 → 수정/삭제

**식단 탭**
- 운동 탭과 동일한 날짜 네비게이션
- 카드에 사진 썸네일 포함
- FAB → BottomSheet: 메모 + 사진 (카메라/갤러리 선택)
- 사진 탭 시 풀스크린 뷰

**알람 탭**
- 알람 목록 (시간 큰 글씨 + 요일 + On/Off 토글)
- FAB → BottomSheet: 시간 피커, 요일, 흔들기 횟수(10–50), 라벨
- 탭 시 수정 / 길게 누름 시 삭제

**알람 울림 화면** (전체화면)
- 큰 시계 + "N번 흔들어서 해제" 진행률 바
- `AlarmRingingBloc`이 가속도계 스트림 구독
- `ShakeDetector`가 임계값(`15.0`) + 디바운스(300ms)로 흔들림 여부 판정
- 목표 횟수 도달 → `BlocListener`가 화면 닫기 + 알람 사운드 정지

---

## iOS vs Android 알람 동작 차이

| | Android | iOS |
|---|---|---|
| 앱 종료 상태에서 알람 화면 강제 표시 | ✅ (`android_alarm_manager_plus` + 풀스크린 인텐트) | ❌ (OS 정책 제한) |
| 알람 소리 | 앱이 직접 재생 | 로컬 알림 사운드 |
| 사용자 개입 필요 | 없음 (자동 화면 열림) | 알림 탭 후 앱 진입 |

> iOS 한계는 어떤 모바일 스택을 써도 동일. 네이티브 Swift로 만들어도 같음.

---

## 구현 단계 (Phase)

| Phase | 내용 | 검증 |
|---|---|---|
| 1 | 프로젝트 부트스트랩: `flutter create`, 의존성, DI 진입점, 빈 3탭 스캐폴드 | `flutter run` 3탭 전환 확인 |
| 2 | **알람 POC 우선 검증**: 로컬 알림/스케줄러, 울림 화면, 흔들기 해제 최소 구현 | **Android/iOS 실기기**에서 OS 제약 확인 |
| 3 | 알람 CRUD: `Alarms` 테이블, `AlarmListCubit`, 알람 탭 UI, 재예약 처리 | 알람 생성·수정·삭제·On/Off 확인 |
| 4 | DB + 운동 탭: `Workouts` 테이블, `WorkoutRepository`, `WorkoutCubit`, CRUD UI | 위젯 테스트 통과 |
| 5 | 식단 탭 + 사진: `Meals` 테이블, `image_picker`, `PhotoStorage`, `MealCubit` | 위젯 테스트 통과 |
| 6 | 달력 네비게이션: `table_calendar` 시트 + 스와이프 날짜 이동 | 날짜별 기록 분리 확인 |
| 7 | 알람 플랫폼 고도화: Android 풀스크린 인텐트, iOS 알림 탭 → 울림 화면 라우팅 | **실기기** 반복 검증 |
| 8 | E2E (`patrol`): 운동·식단 추가, 알람 → 흔들어 해제 시나리오 | 자동화 가능한 범위 통과 + 알람 수동 체크리스트 |

---

## 검증 체크리스트 (각 Phase)

```
□ dart run build_runner build --delete-conflicting-outputs  # 코드 생성 무결
□ flutter analyze                                           # 정적 분석 무결
□ flutter test                                              # 단위·위젯 테스트 통과
□ flutter run -d <simulator>                                # 양 플랫폼 스모크
□ (알람 Phase) 실기기에서 예약·울림·화면 진입·흔들기 해제 확인
□ (알람 Phase) 앱 종료/백그라운드/잠금화면 상태별 동작 확인
```

---

## 확장 예정 (MVP 이후)

- 클라우드 동기화 (Supabase) — Repository 인터페이스 교체
- 일/주 통계 그래프
- 체중·수면·걸음수 (HealthKit / Google Fit)
- 알람 해제 조건 추가 (수학 문제, QR 스캔)
