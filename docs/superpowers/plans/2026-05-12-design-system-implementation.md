# Design System (app_theme) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a reusable `app_theme` package that provides color palettes, typography, and Material 3 ThemeData for the daylog app (Bold Monochrome + Pretendard + Zinc/Red).

**Architecture:** Separate design tokens (raw colors) from semantic ColorScheme, which compose into final ThemeData. Package structure isolates theme concerns and enables reuse across multiple apps.

**Tech Stack:** Flutter Material 3, Pretendard (custom font), local package dependency via path.

---

## File Structure

```
packages/
└── app_theme/
    ├── pubspec.yaml
    ├── lib/
    │   ├── app_theme.dart
    │   └── src/
    │       ├── app_colors.dart
    │       ├── app_color_scheme.dart
    │       ├── app_text_styles.dart
    │       └── app_theme_data.dart
    └── fonts/
        └── Pretendard-Regular.ttf (+ other weights)

Main app:
├── pubspec.yaml (add app_theme dependency)
└── lib/
    └── app.dart (update to use AppThemeData)
```

---

### Task 1: Create app_theme package structure

**Files:**
- Create: `packages/app_theme/pubspec.yaml`
- Create: `packages/app_theme/lib/app_theme.dart`
- Create: `packages/app_theme/lib/src/.gitkeep`

- [ ] **Step 1: Create packages directory and app_theme package folder**

```bash
mkdir -p packages/app_theme/lib/src
mkdir -p packages/app_theme/fonts
```

- [ ] **Step 2: Create pubspec.yaml for app_theme package**

```yaml
name: app_theme
description: Design tokens, color schemes, and Material 3 theme for daylog app.
version: 1.0.0

environment:
  sdk: ^3.11.5

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

Save to: `packages/app_theme/pubspec.yaml`

- [ ] **Step 3: Create barrel export file**

```dart
// lib/app_theme.dart
export 'src/app_colors.dart';
export 'src/app_color_scheme.dart';
export 'src/app_text_styles.dart';
export 'src/app_theme_data.dart';
```

Save to: `packages/app_theme/lib/app_theme.dart`

- [ ] **Step 4: Create empty src files to establish structure**

Create empty files (will fill in next tasks):
- `packages/app_theme/lib/src/app_colors.dart`
- `packages/app_theme/lib/src/app_color_scheme.dart`
- `packages/app_theme/lib/src/app_text_styles.dart`
- `packages/app_theme/lib/src/app_theme_data.dart`

- [ ] **Step 5: Commit**

```bash
cd /Users/no/Desktop/health-app
git add packages/app_theme/pubspec.yaml packages/app_theme/lib/
git commit -m "scaffold: create app_theme package structure"
```

---

### Task 2: Download Pretendard font and add to pubspec

**Files:**
- Create: `packages/app_theme/fonts/Pretendard-*.ttf` (9 weights)
- Modify: `packages/app_theme/pubspec.yaml`

- [ ] **Step 1: Download Pretendard font family**

Download from https://github.com/orioncactus/pretendard/releases (Regular, Medium, SemiBold, Bold)

Save to `packages/app_theme/fonts/` with naming:
- `Pretendard-Regular.ttf` (weight: 400)
- `Pretendard-Medium.ttf` (weight: 500)
- `Pretendard-SemiBold.ttf` (weight: 600)
- `Pretendard-Bold.ttf` (weight: 700)

> For MVP, use 4 weights. If all 9 needed later, download full family.

- [ ] **Step 2: Add fonts section to pubspec.yaml**

```yaml
flutter:
  fonts:
    - family: Pretendard
      fonts:
        - asset: fonts/Pretendard-Regular.ttf
          weight: 400
        - asset: fonts/Pretendard-Medium.ttf
          weight: 500
        - asset: fonts/Pretendard-SemiBold.ttf
          weight: 600
        - asset: fonts/Pretendard-Bold.ttf
          weight: 700
```

Add to: `packages/app_theme/pubspec.yaml` under `flutter:` section

- [ ] **Step 3: Verify font files exist**

```bash
ls -la packages/app_theme/fonts/
```

Expected: 4 `.ttf` files listed

- [ ] **Step 4: Commit**

```bash
git add packages/app_theme/pubspec.yaml packages/app_theme/fonts/
git commit -m "feat: add Pretendard font family"
```

---

### Task 3: Implement AppColors

**Files:**
- Modify: `packages/app_theme/lib/src/app_colors.dart`

- [ ] **Step 1: Write app_colors.dart with all Zinc + Red tokens**

```dart
// lib/src/app_colors.dart
import 'package:flutter/material.dart';

/// Design system color palette (raw tokens, no semantic meaning).
///
/// All colors are `static const` and accessed via [AppColors.zinc900], etc.
/// Do not instantiate this class.
abstract final class AppColors {
  /// Zinc Scale
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc50 = Color(0xFFFAFAFA);

  /// Red Scale (primary accent)
  static const Color red500 = Color(0xFFEF4444);
  static const Color red800 = Color(0xFF991B1B);
  static const Color red200 = Color(0xFFFECACA);
}
```

Save to: `packages/app_theme/lib/src/app_colors.dart`

- [ ] **Step 2: Run analysis to verify no errors**

```bash
cd packages/app_theme
flutter analyze
```

Expected: No errors or warnings.

- [ ] **Step 3: Commit**

```bash
git add packages/app_theme/lib/src/app_colors.dart
git commit -m "feat: define AppColors palette tokens"
```

---

### Task 4: Implement AppColorScheme

**Files:**
- Modify: `packages/app_theme/lib/src/app_color_scheme.dart`

- [ ] **Step 1: Write app_color_scheme.dart with light/dark ColorScheme**

```dart
// lib/src/app_color_scheme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Material 3 ColorScheme definitions for daylog.
///
/// Light and dark schemes are explicitly defined with all tokens mapped
/// to AppColors — ColorScheme.fromSeed is not used to preserve Zinc
/// background colors.
abstract final class AppColorScheme {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.red500,
    onPrimary: AppColors.zinc50,
    primaryContainer: AppColors.red200,
    onPrimaryContainer: AppColors.red800,
    secondary: AppColors.zinc500,
    onSecondary: AppColors.zinc50,
    surface: AppColors.zinc50,
    onSurface: AppColors.zinc900,
    surfaceContainerHighest: AppColors.zinc100,
    onSurfaceVariant: AppColors.zinc500,
    outline: AppColors.zinc200,
    outlineVariant: AppColors.zinc100,
    error: AppColors.red500,
    onError: AppColors.zinc50,
    errorContainer: AppColors.red200,
    onErrorContainer: AppColors.red800,
    shadow: Color(0x1A000000),
    scrim: Color(0x1A000000),
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.red500,
    onPrimary: AppColors.zinc50,
    primaryContainer: AppColors.red800,
    onPrimaryContainer: AppColors.red200,
    secondary: AppColors.zinc400,
    onSecondary: AppColors.zinc900,
    surface: AppColors.zinc900,
    onSurface: AppColors.zinc50,
    surfaceContainerHighest: AppColors.zinc800,
    onSurfaceVariant: AppColors.zinc400,
    outline: AppColors.zinc700,
    outlineVariant: AppColors.zinc700,
    error: AppColors.red500,
    onError: AppColors.zinc50,
    errorContainer: AppColors.red800,
    onErrorContainer: AppColors.red200,
    shadow: Color(0x1A000000),
    scrim: Color(0x1A000000),
  );
}
```

Save to: `packages/app_theme/lib/src/app_color_scheme.dart`

- [ ] **Step 2: Run analysis**

```bash
cd packages/app_theme
flutter analyze
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add packages/app_theme/lib/src/app_color_scheme.dart
git commit -m "feat: define light/dark ColorScheme"
```

---

### Task 5: Implement AppTextStyles

**Files:**
- Modify: `packages/app_theme/lib/src/app_text_styles.dart`

- [ ] **Step 1: Write app_text_styles.dart with Material 3 TextTheme**

```dart
// lib/src/app_text_styles.dart
import 'package:flutter/material.dart';

/// Material 3 typography scale for daylog (Pretendard).
///
/// All text styles use fontFamily 'Pretendard'. Color is not set here;
/// it's inherited from ColorScheme.onSurface at runtime.
abstract final class AppTextStyles {
  static const String _fontFamily = 'Pretendard';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      fontFamily: _fontFamily,
      letterSpacing: 0,
    ),
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      fontFamily: _fontFamily,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      fontFamily: _fontFamily,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontFamily: _fontFamily,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: _fontFamily,
      letterSpacing: 0,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: _fontFamily,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      fontFamily: _fontFamily,
      letterSpacing: 0,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontFamily: _fontFamily,
      letterSpacing: 0,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      fontFamily: _fontFamily,
      letterSpacing: 0,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: _fontFamily,
      letterSpacing: 0,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      fontFamily: _fontFamily,
      letterSpacing: 0,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      fontFamily: _fontFamily,
      letterSpacing: 0.05,
    ),
  );
}
```

Save to: `packages/app_theme/lib/src/app_text_styles.dart`

- [ ] **Step 2: Run analysis**

```bash
cd packages/app_theme
flutter analyze
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add packages/app_theme/lib/src/app_text_styles.dart
git commit -m "feat: define TextTheme with Pretendard"
```

---

### Task 6: Implement AppThemeData

**Files:**
- Modify: `packages/app_theme/lib/src/app_theme_data.dart`

- [ ] **Step 1: Write app_theme_data.dart with light/dark ThemeData**

```dart
// lib/src/app_theme_data.dart
import 'package:flutter/material.dart';
import 'app_color_scheme.dart';
import 'app_text_styles.dart';

/// Material 3 ThemeData for daylog app.
///
/// Exports static `light` and `dark` ThemeData instances with all
/// component shape, typography, and color overrides.
abstract final class AppThemeData {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: AppColorScheme.light,
        textTheme: AppTextStyles.textTheme,
        scaffoldBackgroundColor: AppColorScheme.light.surface,
        cardTheme: CardTheme(
          color: AppColorScheme.light.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: AppColorScheme.dark,
        textTheme: AppTextStyles.textTheme,
        scaffoldBackgroundColor: AppColorScheme.dark.surface,
        cardTheme: CardTheme(
          color: AppColorScheme.dark.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF3F3F46)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
        ),
      );
}
```

Save to: `packages/app_theme/lib/src/app_theme_data.dart`

- [ ] **Step 2: Run analysis**

```bash
cd packages/app_theme
flutter analyze
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add packages/app_theme/lib/src/app_theme_data.dart
git commit -m "feat: define light/dark ThemeData"
```

---

### Task 7: Add app_theme dependency to main app

**Files:**
- Modify: `pubspec.yaml` (at root of health-app)

- [ ] **Step 1: Add local app_theme path dependency**

In main app's `pubspec.yaml`, under `dependencies:`, add:

```yaml
app_theme:
  path: packages/app_theme
```

Final structure:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  app_theme:
    path: packages/app_theme
```

Save to: `/Users/no/Desktop/health-app/pubspec.yaml`

- [ ] **Step 2: Run flutter pub get to resolve dependencies**

```bash
cd /Users/no/Desktop/health-app
flutter pub get
```

Expected: Output includes "Got dependencies" or similar.

- [ ] **Step 3: Verify app_theme package is accessible**

```bash
flutter pub get
```

Check for any errors. If successful, continue.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat: add app_theme local package dependency"
```

---

### Task 8: Update app.dart to use AppThemeData

**Files:**
- Modify: `lib/app.dart` (create if doesn't exist)

- [ ] **Step 1: Check if app.dart exists; if not, create it**

```bash
ls -la lib/app.dart
```

If not found, create it. Otherwise, proceed to modify existing file.

- [ ] **Step 2: Update app.dart to import and use AppThemeData**

```dart
import 'package:flutter/material.dart';
import 'package:app_theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'daylog',
      theme: AppThemeData.light,
      darkTheme: AppThemeData.dark,
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'daylog Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

Save to: `lib/app.dart`

- [ ] **Step 3: Update main.dart to import and run MyApp**

```dart
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const MyApp());
}
```

Save to: `lib/main.dart`

- [ ] **Step 4: Run flutter analyze to check for errors**

```bash
cd /Users/no/Desktop/health-app
flutter analyze
```

Expected: No errors related to app_theme imports or ThemeData usage.

- [ ] **Step 5: Commit**

```bash
git add lib/app.dart lib/main.dart
git commit -m "feat: apply AppThemeData to MaterialApp"
```

---

### Task 9: Test theme in emulator/simulator

**Files:**
- No files created/modified (testing only)

- [ ] **Step 1: Clean and build**

```bash
cd /Users/no/Desktop/health-app
flutter clean
flutter pub get
```

Expected: No errors.

- [ ] **Step 2: Run app on default device**

```bash
flutter run -d <device_id>
```

(Replace `<device_id>` with output from `flutter devices` if needed. Common: `-d chrome` for web, emulator ID for Android/iOS.)

Expected: App launches without crashes.

- [ ] **Step 3: Verify theme applied**

Visually inspect:
- **Light mode**: White background, black text, red accents
- **Dark mode**: Near-black background, light text, red accents
- **Font**: Pretendard rendering (check that text is visually different from default sans-serif)
- **Border radius**: Sharp 4px corners on cards/buttons (if visible in demo UI)

Change device theme in OS settings to switch between light/dark — app should adapt in real time.

- [ ] **Step 4: Test in both light and dark mode (if on physical device or simulator with settings)**

- [ ] **Step 5: No code commit needed** (testing only)

---

## Plan Self-Review

**Spec coverage:**
- ✅ Package structure (Task 1)
- ✅ Pretendard font (Task 2)
- ✅ AppColors palette (Task 3)
- ✅ AppColorScheme light/dark (Task 4)
- ✅ AppTextStyles with typography scale (Task 5)
- ✅ AppThemeData with component overrides (Task 6)
- ✅ Integration into main app (Tasks 7-8)
- ✅ Verification (Task 9)

**Placeholder scan:** None found. All code blocks are complete.

**Type consistency:** ColorScheme token names (e.g., `zinc900`, `red500`) used consistently across all tasks.

**No gaps identified.**

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-12-design-system-implementation.md`.

Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review results between tasks, fast iteration.

**2. Inline Execution** - I execute tasks in this session using executing-plans, batched with checkpoints for review.

**Which approach?**
