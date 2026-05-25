---
name: design-system
description: Color palette, typography, spacing, and theme conventions for the health app
metadata:
  type: project
---

## Color palette (AppColors / AppColorScheme)

- Primary: `AppColors.red500` — accent for selected states, FAB, buttons
- Surface: `AppColors.zinc50` (light) / `AppColors.zinc900` (dark)
- SurfaceContainerHighest: `AppColors.zinc100` (light) / `AppColors.zinc800` (dark) — used for filled chips, input backgrounds
- OnSurfaceVariant: `AppColors.zinc500` (light) / `AppColors.zinc400` (dark) — secondary text, icons
- Outline: `AppColors.zinc200` (light) / `AppColors.zinc700` (dark)

## Typography (AppTextStyles — Pretendard font)

- `displayMedium` 45sp w400 — large time display (alarm clock)
- `displaySmall` 36sp w400 — alarm list time
- `headlineSmall` 24sp w600 — screen title (TabScaffold)
- `titleLarge` 22sp w600 — bottom sheet title
- `titleMedium` 16sp w500 — list tile primary
- `titleSmall` 14sp w500 — section label
- `labelMedium` 12sp w500 ls0.5 — chips, weekday buttons
- `bodyMedium` 14sp w400 — secondary/description text
- `bodySmall` 12sp w400 — tertiary text

## Spacing conventions

Base-8 grid. Common values: 4, 6, 8, 12, 14, 16, 18, 20, 24, 32.
Bottom sheet padding: `EdgeInsets.fromLTRB(24, 0, 24, bottomPadding)`.

## Border radii

- Cards: 16
- Inputs: 12
- Buttons: 12 (elevated), 20 (pill/preset chips)
- Bottom sheet top corners: 24
- FAB: 16
- Circular day buttons: `BoxShape.circle`

## Animation

- Short state transitions: 180ms, `Curves.easeOut` — used on chip/button color changes.

**Why:** Consistent with Material 3 motion guidelines; short enough to feel snappy.
