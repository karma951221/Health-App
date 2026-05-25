import 'package:feature_alarm/feature_alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Weekday bitmask constants (bit 0 = 월, bit 6 = 일)
const int _kWeekdayMaskWeekdays = 0x1F; // 월~금 (bits 0–4)
const int _kWeekdayMaskWeekend = 0x60;  // 토~일 (bits 5–6)
const int _kWeekdayMaskAll = 0x7F;      // 전체

// Shake-count stepper bounds
const int _kShakeMin = 5;
const int _kShakeMax = 100;
const int _kShakeStep = 5;

class AlarmEntrySection extends StatelessWidget {
  const AlarmEntrySection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<AlarmEditCubit, AlarmEditState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel('시간'),
            const SizedBox(height: 12),
            _TimeDisplay(alarm: state.alarm),
            const SizedBox(height: 28),
            Divider(height: 1, thickness: 1, color: colors.outlineVariant),
            const SizedBox(height: 28),
            const _SectionLabel('반복 요일'),
            const SizedBox(height: 16),
            _WeekdaySelector(alarm: state.alarm),
            const SizedBox(height: 28),
            Divider(height: 1, thickness: 1, color: colors.outlineVariant),
            const SizedBox(height: 28),
            const _SectionLabel('흔들기 횟수'),
            const SizedBox(height: 12),
            _ShakeCountStepper(alarm: state.alarm),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Section label — shared heading for the time and weekday groups
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Time display — tappable large clock text that opens the native TimePicker
// ---------------------------------------------------------------------------

class _TimeDisplay extends StatelessWidget {
  const _TimeDisplay({required this.alarm});

  final Alarm alarm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final hour = alarm.hour.toString().padLeft(2, '0');
    final minute = alarm.minute.toString().padLeft(2, '0');

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: alarm.hour, minute: alarm.minute),
          );
          if (picked != null && context.mounted) {
            context.read<AlarmEditCubit>().updateTime(picked.hour, picked.minute);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$hour:$minute',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekday selector — preset row + circular day buttons
// ---------------------------------------------------------------------------

class _WeekdaySelector extends StatelessWidget {
  const _WeekdaySelector({required this.alarm});

  final Alarm alarm;

  void _toggleDay(BuildContext context, int dayIndex) {
    final current = alarm.weekdayMask;
    final bit = 1 << dayIndex;
    final next = (current & bit) != 0 ? current & ~bit : current | bit;
    context.read<AlarmEditCubit>().updateWeekdays(next);
  }

  void _applyPreset(BuildContext context, int mask) {
    context.read<AlarmEditCubit>().updateWeekdays(mask);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preset quick-select segmented control
        _PresetRow(
          currentMask: alarm.weekdayMask,
          onSelect: (mask) => _applyPreset(context, mask),
        ),
        const SizedBox(height: 16),

        // Individual day buttons
        Row(
          children: List.generate(7, (i) {
            final labels = ['월', '화', '수', '목', '금', '토', '일'];
            final isSelected = (alarm.weekdayMask & (1 << i)) != 0;
            final isWeekend = i >= 5;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 6 ? 6 : 0),
                child: _DayButton(
                  label: labels[i],
                  selected: isSelected,
                  isWeekend: isWeekend,
                  onTap: () => _toggleDay(context, i),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Preset row — gray segmented control (주말만 / 평일만 / 전체요일)
//
// Intentionally uses neutral grays only — the accent red is reserved for the
// day buttons so the two controls never read as the same selection state.
// ---------------------------------------------------------------------------

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.currentMask,
    required this.onSelect,
  });

  final int currentMask;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _PresetSegment(
            label: '주말만',
            active: currentMask == _kWeekdayMaskWeekend,
            onTap: () => onSelect(_kWeekdayMaskWeekend),
          ),
          _PresetSegment(
            label: '평일만',
            active: currentMask == _kWeekdayMaskWeekdays,
            onTap: () => onSelect(_kWeekdayMaskWeekdays),
          ),
          _PresetSegment(
            label: '전체요일',
            active: currentMask == _kWeekdayMaskAll,
            onTap: () => onSelect(_kWeekdayMaskAll),
          ),
        ],
      ),
    );
  }
}

class _PresetSegment extends StatelessWidget {
  const _PresetSegment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final fgColor = active ? colors.onSecondary : colors.onSurfaceVariant;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? colors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: fgColor,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual day button — circular, accent-filled when selected
// ---------------------------------------------------------------------------

class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.label,
    required this.selected,
    required this.isWeekend,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isWeekend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Unselected weekend tint (subtle red hint without being selected)
    final unselectedFg = isWeekend
        ? colors.primary.withValues(alpha: 0.6)
        : colors.onSurfaceVariant;

    final bgColor = selected ? colors.primary : colors.surfaceContainerHighest;
    final fgColor = selected ? colors.onPrimary : unselectedFg;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: fgColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shake-count stepper — neutral −/+ control (no accent red)
// ---------------------------------------------------------------------------

class _ShakeCountStepper extends StatelessWidget {
  const _ShakeCountStepper({required this.alarm});

  final Alarm alarm;

  void _set(BuildContext context, int value) {
    context.read<AlarmEditCubit>().updateShakeCount(value.clamp(_kShakeMin, _kShakeMax));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final count = alarm.shakeCount;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepButton(
              icon: Icons.remove,
              enabled: count > _kShakeMin,
              onTap: () => _set(context, count - _kShakeStep),
            ),
            SizedBox(
              width: 72,
              child: Text(
                '$count회',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ),
            _StepButton(
              icon: Icons.add,
              enabled: count < _kShakeMax,
              onTap: () => _set(context, count + _kShakeStep),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: enabled ? colors.onSurface : colors.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}