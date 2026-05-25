# Daylog — 설계 문서

> 흔들어야 꺼지는 미라클 모닝 알람 + 해제 직후 오늘 날씨를 보여주는 굿모닝 브리핑

---

## 핵심 목적

- **흔들어야만 꺼지는 알람**으로 기상 습관을 강제한다.
- 알람을 해제하면 **굿모닝 브리핑**이 떠서 오늘 아침에 필요한 정보(현재 날씨)를 보여준다 — "일어날 이유"를 만든다.
- 개인용 MVP — 인증·서버 없이 디바이스 로컬 저장 + 외부 날씨 API(open-meteo) 호출.

> **피벗 노트:** 본래 운동·식단 기록 + 알람의 3탭 헬스 앱이었으나, 알람을 핵심으로 남기고 운동·식단은 제거했다. 부가 가치로 아침 날씨 브리핑을 붙였다.

---

## 기술 스택

| 역할 | 패키지 |
|---|---|
| 플랫폼 | Flutter (Android 우선, iOS 후속) |
| 상태 관리 | `flutter_bloc` (Cubit / Bloc) |
| 의존성 주입 | `provider` (MultiProvider 기반 수동 주입) |
| DB | `drift` (타입 안전 SQLite) — `infra_local_db` 패키지 |
| 알람 | `alarm` (사운드·풀스크린·앱 종료 대응) |
| 권한 | `permission_handler` (알림·정확한 알람) |
| 위치 | `geolocator` (날씨용 GPS) |
| 네트워크 | `http` (open-meteo 호출) |
| 날씨 | open-meteo (무료, API 키 불필요) |

### 알려진 미구현 / 후속
- **실제 흔들기 센서**: 울림 화면의 흔들기는 현재 버튼 mock. `sensors_plus` 연동은 후속.
- **지하철 실시간 도착 정보**: 브리핑 v2.
- **iOS**: 위치/알림 권한 및 풀스크린 동작 마감은 후속(현재 Android 우선).

---

## 데이터 모델

```dart
// 알람 (drift)
class Alarms extends Table {
  IntColumn      get id              => integer().autoIncrement()();
  IntColumn      get hour            => integer()();
  IntColumn      get minute          => integer()();
  IntColumn      get weekdayMask     => integer()();  // 7비트 (월=bit0 … 일=bit6), 0=일회성
  DateTimeColumn get oneShotDate     => dateTime().nullable()();
  DateTimeColumn get nextScheduledAt => dateTime().nullable()();
  BoolColumn     get enabled         => boolean().withDefault(const Constant(true))();
  IntColumn      get shakeCount      => integer().withDefault(const Constant(20))();
  TextColumn     get label           => text().withDefault(const Constant('미라클 모닝'))();
}
```

> 날씨는 영속화하지 않는다. 브리핑 진입 시 open-meteo에서 실시간 조회한다.

---

## 화면 흐름

단일 화면 앱(하단 탭 없음).

**알람 화면 (홈)**
- AppBar "알람" + 알람 목록 (시간 큰 글씨 + 라벨 + 요일 + On/Off 토글)
- 스와이프로 삭제
- FAB → BottomSheet: 시간 피커, 반복 요일, 흔들기 횟수(5–100), (라벨)
- 카드 탭 → 수정 시트

**알람 울림 화면** (전체화면)
- 큰 시계 + 라벨 + "N번 흔들어서 해제" 진행률 바
- 목표 횟수 도달 → 알람 정지 후 **굿모닝 브리핑으로 이동**(`pushReplacement`)
- 좌상단 닫기(x) → 알람만 정지하고 브리핑 없이 종료(중단 경로)

**굿모닝 브리핑 화면**
- "좋은 아침이에요" + 오늘 날짜/시각
- 현재 기온 + 날씨 상태 + 당일 최고/최저
- 상태별 처리: 로딩 / 성공 / 위치권한 거부(재요청) / 영구거부(설정 열기) / 위치서비스 꺼짐(재시도) / 실패(재시도)
- "시작하기" → 홈으로

---

## 권한 흐름

- **알람**: 부팅 시 `permission_handler`로 알림·정확한 알람 권한 요청 (DI 부트스트래퍼).
- **위치(날씨)**: 브리핑 첫 진입 시 `geolocator`로 지연 요청. 거부/영구거부/서비스꺼짐을 구분해 브리핑 화면에서 안내 + 설정 이동.

---

## 프로젝트 구조 (요지)

```
lib/
├── main.dart
├── core/
│   ├── dependency_injection/dependency_injection.dart  # Provider 주입 + 알람 부트스트랩
│   ├── notifications/        # alarm 패키지 래퍼(AlarmRingerService 등)
│   ├── navigation/app_navigator.dart
│   └── weather/weather_service.dart                    # open-meteo + MorningWeather 모델
└── features/
    ├── home/home_screen.dart            # 단일 알람 화면 셸
    ├── alarm/                           # 목록·편집·울림 화면
    ├── briefing/                        # 굿모닝 브리핑 화면 + Cubit
    └── shared/shared_widget.dart

packages/
├── app_ui, app_theme, app_shared        # 디자인 시스템·공용 위젯
├── feature_alarm                        # 알람 도메인·데이터·프레젠테이션
└── infra_local_db                       # drift DB
```

---

## 구현 단계 (Phase)

| Phase | 내용 | 검증 |
|---|---|---|
| 1 | 피벗: 운동·식단 제거, 단일 알람 화면 정리 | `flutter analyze` 무결 |
| 2 | 굿모닝 브리핑(날씨): WeatherService(open-meteo) + 브리핑 화면/Cubit + 위치권한 | 권한 허용/거부 분기 + 날씨 표시 |
| 3 | 울림 → 브리핑 연결 (정상 해제 시 진입) | 알림→울림→해제→브리핑 흐름 |
| 4 | (후속) 실제 흔들기 센서(`sensors_plus`) 연동 | 실기기 흔들기 해제 |
| 5 | (후속) 지하철 실시간 도착 정보 브리핑 v2 | — |
| 6 | (후속) iOS 권한·풀스크린 마감 | 실기기 |

---

## 검증 체크리스트

```
□ flutter pub get
□ flutter analyze         # 정적 분석 무결
□ flutter test            # 단위·위젯 테스트 (날씨 파싱 포함)
□ flutter run -d <device> # 알람 추가/수정, 울림→해제→브리핑, 날씨 표시/거부 안내
□ (알람) 실기기에서 예약·울림·화면 진입·(mock)흔들기 해제 확인
```
