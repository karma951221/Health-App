import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

import '../briefing/morning_briefing_screen.dart';

class AlarmRingingScreen extends StatefulWidget {
  const AlarmRingingScreen({
    super.key,
    this.alarmId,
    this.hour = 5,
    this.minute = 30,
    this.label = '미라클 모닝',
    this.shakeTarget = 20,
    this.onDismiss,
  });

  final int? alarmId;
  final int hour;
  final int minute;
  final String label;
  final int shakeTarget;

  /// Called when the alarm is dismissed — stops the ringing alarm and
  /// advances repeating alarms to their next occurrence.
  final VoidCallback? onDismiss;

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  int _count = 0;

  /// 흔들기 없이 닫기(x) — 알람만 정지하고 브리핑은 띄우지 않는다.
  void _abort() {
    widget.onDismiss?.call();
    Navigator.of(context).pop();
  }

  /// 목표 횟수를 채워 정상 해제 — 알람 정지 후 굿모닝 브리핑으로 이동.
  void _complete() {
    widget.onDismiss?.call();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const MorningBriefingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final target = widget.shakeTarget;
    final hour = widget.hour.toString().padLeft(2, '0');
    final minute = widget.minute.toString().padLeft(2, '0');
    final progress = _count / target;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _abort,
                  icon: const Icon(Icons.close),
                  tooltip: '닫기',
                ),
              ),
              const Spacer(),
              Text(
                '$hour:$minute',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.label.isEmpty ? '알람' : widget.label,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '$target번 흔들어서 해제',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 12,
                  value: progress.clamp(0, 1),
                  backgroundColor: colors.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 12),
              Text('$_count / $target', style: theme.textTheme.titleMedium),
              const Spacer(),
              AppPrimaryButton(
                label: _count >= target ? '해제 완료' : '흔들림 추가',
                onPressed: () {
                  if (_count >= target) {
                    _complete();
                    return;
                  }
                  setState(() {
                    _count += 1;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
