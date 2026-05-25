import 'package:app_ui/app_ui.dart';
import 'package:feature_alarm/feature_alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../shared/shared_widget.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({
    super.key,
    this.onEditAlarm,
  });

  final void Function(Alarm)? onEditAlarm;

  @override
  Widget build(BuildContext context) {
    return AlarmListView(
      onEditAlarm: onEditAlarm,
    );
  }
}

class AlarmListView extends StatelessWidget {
  const AlarmListView({
    super.key,
    this.onEditAlarm,
  });

  final void Function(Alarm)? onEditAlarm;

  String _formatWeekdays(int mask) {
    if (mask == 0) return '일회성';
    if (mask == 127) return '매일';
    if (mask == 31) return '평일';
    if (mask == 96) return '주말';

    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final selected = <String>[];
    for (int i = 0; i < 7; i++) {
      if ((mask & (1 << i)) != 0) {
        selected.add(days[i]);
      }
    }
    return selected.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TabScaffold(
      title: '알람',
      subtitle: '일어나야 꺼지는 아침 루틴을 준비해요.',
      child: BlocBuilder<AlarmListBloc, AlarmListState>(
        builder: (context, state) {
          if (state.status == AlarmListStatus.loading) {
            return const Padding(
              padding: EdgeInsets.only(top: 100),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == AlarmListStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? '알람을 불러오지 못했습니다.'),
                  TextButton(
                    onPressed: () => context.read<AlarmListBloc>().add(const AlarmListEvent.started()),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (state.alarms.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 60),
              child: EmptyState(
                icon: Icons.alarm_off_outlined,
                title: '설정된 알람이 없어요',
                body: '아래 + 버튼을 눌러 새 알람을 추가해보세요.',
              ),
            );
          }

          return Column(
            children: [
              for (final alarm in state.alarms)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey('alarm_${alarm.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
                    ),
                    onDismissed: (_) {
                      if (alarm.id != null) {
                        context.read<AlarmListBloc>().add(AlarmListEvent.deleted(id: alarm.id!));
                      }
                    },
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onEditAlarm?.call(alarm),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${alarm.hour.toString().padLeft(2, '0')}:${alarm.minute.toString().padLeft(2, '0')}',
                                      style: theme.textTheme.displaySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: alarm.enabled ? colors.onSurface : colors.onSurface.withValues(alpha: 0.38),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${alarm.label.isEmpty ? '알람' : alarm.label} · ${_formatWeekdays(alarm.weekdayMask)}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: alarm.enabled ? colors.onSurface : colors.onSurface.withValues(alpha: 0.38),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '흔들기 ${alarm.shakeCount}회',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: alarm.enabled,
                                onChanged: (value) {
                                  context.read<AlarmListBloc>().add(
                                        AlarmListEvent.toggled(
                                          alarm: alarm,
                                          enabled: value,
                                        ),
                                      );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
