# Design System — app_theme 패키지

> daylog 앱의 컬러 팔레트, 타이포그래피, ThemeData를 격리된 로컬 패키지로 정의한다.

---

## 결정 요약

| 항목 | 결정 |
|---|---|
| 무드 | Bold Monochrome (흑백 + 레드 포인트) |
| 테마 모드 | `ThemeMode.system` (다크/라이트 자동 전환) |
| Material 버전 | Material 3 (`useMaterial3: true`) |
| 폰트 | Pretendard |
| 팔레트 | Zinc 스케일 + Red-500 |
| Border radius | Sharp — 4 (BottomSheet 상단만 예외 12) |

---

## 패키지 구조

```
packages/
└── app_theme/
    ├── pubspec.yaml
    └── lib/
        ├── app_theme.dart          # barrel export
        └── src/
            ├── app_colors.dart         # raw 팔레트 상수
            ├── app_color_scheme.dart   # light/dark ColorScheme
            ├── app_text_styles.dart    # TextTheme (Pretendard)
            └── app_theme_data.dart     # 최종 ThemeData 조립
```

메인 앱 `pubspec.yaml`에 로컬 경로 의존성으로 추가:

```yaml
dependencies:
  app_theme:
    path: ../packages/app_theme
```

---

## AppColors

`abstract final class` — `static const`만 보유, 인스턴스화 불가.

### Zinc 스케일

| 토큰 | 값 | 용도 |
|---|---|---|
| `zinc900` | `#18181B` | 다크 배경 |
| `zinc800` | `#27272A` | 다크 카드 서피스 |
| `zinc700` | `#3F3F46` | 다크 border / divider |
| `zinc500` | `#71717A` | 라이트 secondary text |
| `zinc400` | `#A1A1AA` | 다크 secondary text |
| `zinc200` | `#E4E4E7` | 라이트 border / divider |
| `zinc100` | `#F4F4F5` | 라이트 카드 서피스 |
| `zinc50` | `#FAFAFA` | 다크 on-surface text, 라이트 배경 |

### Red 스케일

| 토큰 | 값 | 용도 |
|---|---|---|
| `red500` | `#EF4444` | primary accent (양 모드 공통) |
| `red800` | `#991B1B` | 다크 primaryContainer |
| `red200` | `#FECACA` | 라이트 primaryContainer |

---

## AppColorScheme

`ColorScheme.fromSeed` 미사용 — Zinc 배경색이 M3 자동 생성값으로 덮어씌워지지 않도록 전 토큰 명시 지정.

### Dark

| M3 토큰 | 값 |
|---|---|
| `brightness` | `Brightness.dark` |
| `primary` | `red500` |
| `onPrimary` | `zinc50` |
| `primaryContainer` | `red800` |
| `onPrimaryContainer` | `red200` |
| `surface` | `zinc900` |
| `onSurface` | `zinc50` |
| `surfaceContainerHighest` | `zinc800` |
| `onSurfaceVariant` | `zinc400` |
| `outline` | `zinc700` |
| `error` | `red500` |

### Light

| M3 토큰 | 값 |
|---|---|
| `brightness` | `Brightness.light` |
| `primary` | `red500` |
| `onPrimary` | `zinc50` |
| `primaryContainer` | `red200` |
| `onPrimaryContainer` | `red800` |
| `surface` | `zinc50` |
| `onSurface` | `zinc900` |
| `surfaceContainerHighest` | `zinc100` |
| `onSurfaceVariant` | `zinc500` |
| `outline` | `zinc200` |
| `error` | `red500` |

---

## AppTextStyles

fontFamily `'Pretendard'` 전체 공통. color는 지정하지 않고 ColorScheme `onSurface` 상속.

| M3 토큰 | size | weight | 용도 |
|---|---|---|---|
| `displayLarge` | 40 | 700 | 알람 울림 화면 시계 |
| `headlineLarge` | 28 | 700 | 탭 헤더, 날짜 |
| `headlineMedium` | 24 | 700 | 섹션 타이틀 |
| `titleLarge` | 18 | 700 | BottomSheet 제목 |
| `titleMedium` | 16 | 600 | 카드 메인 텍스트 |
| `titleSmall` | 14 | 600 | 카드 서브, 라벨 |
| `bodyLarge` | 16 | 400 | 메모 입력 필드, 긴 본문 |
| `bodyMedium` | 14 | 400 | 본문 메모 텍스트 |
| `bodySmall` | 12 | 400 | 타임스탬프, 설명 |
| `labelLarge` | 14 | 600 | 버튼 텍스트, BottomNav 라벨 |
| `labelMedium` | 12 | 600 | 요일 선택 칩 (월/화/수…) |
| `labelSmall` | 10 | 700 | 태그 칩, 작은 배지 |

`labelSmall`만 `letterSpacing: 0.05` 적용 (태그 가독성).

---

## AppThemeData

`AppThemeData.light` / `AppThemeData.dark` 두 개의 static `ThemeData`를 노출.

### 공통 컴포넌트 오버라이드

| 컴포넌트 | shape |
|---|---|
| `CardTheme` | `RoundedRectangleBorder(radius: 4)` |
| `FilledButtonThemeData` | `RoundedRectangleBorder(radius: 4)` |
| `FloatingActionButtonThemeData` | `RoundedRectangleBorder(radius: 4)` |
| `InputDecorationTheme` border | `OutlineInputBorder(radius: 4)` |
| `BottomSheetThemeData` | `RoundedRectangleBorder(topLeft: 12, topRight: 12)` |

> BottomSheet 상단만 radius 12 — 슬라이드 업 애니메이션 자연스러움을 위한 예외.

### 사용 예시

```dart
// app.dart
MaterialApp(
  theme: AppThemeData.light,
  darkTheme: AppThemeData.dark,
  themeMode: ThemeMode.system,
)
```

### barrel export (app_theme.dart)

```dart
export 'src/app_colors.dart';
export 'src/app_color_scheme.dart';
export 'src/app_text_styles.dart';
export 'src/app_theme_data.dart';
```
