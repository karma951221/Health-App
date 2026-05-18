import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class AlarmRingingScreen extends StatefulWidget {
  const AlarmRingingScreen({super.key});

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  static const _target = 20;
  int _count = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = _count / _target;

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
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: '닫기',
                ),
              ),
              const Spacer(),
              Text(
                '05:30',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text('미라클 모닝', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                '$_target번 흔들어서 해제',
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
              Text('$_count / $_target', style: theme.textTheme.titleMedium),
              const Spacer(),
              AppPrimaryButton(
                label: _count >= _target ? '해제 완료' : '흔들림 추가',
                onPressed: () {
                  if (_count >= _target) {
                    Navigator.of(context).pop();
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
