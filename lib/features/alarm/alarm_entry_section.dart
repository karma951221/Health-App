import 'package:feature_alarm/feature_alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlarmEntrySection extends StatefulWidget {
  const AlarmEntrySection({super.key});

  @override
  State<AlarmEntrySection> createState() => _AlarmEntrySectionState();
}

class _AlarmEntrySectionState extends State<AlarmEntrySection> {
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    final initialLabel = context.read<AlarmEditCubit>().state.alarm.label;
    _labelController = TextEditingController(text: initialLabel);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ['월', '화', '수', '목', '금', '토', '일'];

    return BlocListener<AlarmEditCubit, AlarmEditState>(
      listenWhen: (previous, current) => previous.alarm.label != current.alarm.label,
      listener: (context, state) {
        if (_labelController.text != state.alarm.label) {
          _labelController.text = state.alarm.label;
        }
      },
      child: BlocBuilder<AlarmEditCubit, AlarmEditState>(
        builder: (context, state) {
          final alarm = state.alarm;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: alarm.hour, minute: alarm.minute),
                    );
                    if (time != null && context.mounted) {
                      context.read<AlarmEditCubit>().updateTime(time.hour, time.minute);
                    }
                  },
                  child: Text(
                    '${alarm.hour.toString().padLeft(2, '0')} : ${alarm.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                children: [
                  for (int i = 0; i < days.length; i++)
                    ChoiceChip(
                      label: Text(days[i]),
                      selected: (alarm.weekdayMask & (1 << i)) != 0,
                      onSelected: (selected) {
                        int newMask = alarm.weekdayMask;
                        if (selected) {
                          newMask |= (1 << i);
                        } else {
                          newMask &= ~(1 << i);
                        }
                        context.read<AlarmEditCubit>().updateWeekdays(newMask);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text('흔들어서 해제: ${alarm.shakeCount}회', style: theme.textTheme.titleSmall),
              Slider(
                value: alarm.shakeCount.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                label: '${alarm.shakeCount}',
                onChanged: (value) {
                  context.read<AlarmEditCubit>().updateShakeCount(value.toInt());
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(hintText: '알람 이름 (예: 미라클 모닝)'),
                onChanged: (value) {
                  context.read<AlarmEditCubit>().updateLabel(value);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
