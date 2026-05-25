---
name: ui-patterns
description: Recurring UI patterns, screen structure, and component conventions in the health app
metadata:
  type: project
---

## Entry sheet pattern

All add/edit flows use `showModalBottomSheet` + `AppBottomSheetScaffold` with:
- `BlocProvider` wrapping to inject the Cubit
- `BlocConsumer` listening for success/failure status
- `AppPrimaryButton` as the `action` param for the save CTA

## AlarmEntrySection (alarm add/edit bottom sheet)

Location: `lib/features/alarm/alarm_entry_section.dart`

### Post-redesign structure (2026-05-24)
- `_TimeDisplay` — center-aligned tappable container (surfaceContainerHighest bg, displayMedium text) opening native TimePicker
- `_WeekdaySelector` — section label + `_PresetRow` + 7× `_DayButton` in a `Row`
- `_PresetRow` — three `_PresetChip` buttons: 주말만 (mask 0x60), 평일만 (mask 0x1F), 전체요일 (mask 0x7F)
- `_DayButton` — circular `AnimatedContainer`, 40px height, Expanded in Row (equal width)

### Removed from entry sheet
- Shake count `Slider` (흔들기 해제 횟수)
- Label `TextField` (알람 이름)
These were removed to keep the sheet minimal (time + repeat days only).

## Weekday bitmask convention

Bit 0 = 월, Bit 1 = 화, ..., Bit 4 = 금, Bit 5 = 토, Bit 6 = 일.
- Weekdays (평일): 0x1F (bits 0–4)
- Weekend (주말): 0x60 (bits 5–6)
- All days (전체): 0x7F

## TabScaffold

`lib/features/shared/shared_widget.dart` — ListView wrapper with page title/subtitle header and optional trailing widget. Padding: `fromLTRB(20, 8, 20, 96)`.

## AlarmListBloc / AlarmEditCubit

- `AlarmListBloc` handles list CRUD events (started, deleted, toggled)
- `AlarmEditCubit` handles field mutations (updateTime, updateWeekdays, updateShakeCount, updateLabel) + save()
- Both live in `packages/feature_alarm`
