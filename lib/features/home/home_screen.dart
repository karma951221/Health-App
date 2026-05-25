import 'package:app_ui/app_ui.dart';
import 'package:feature_alarm/feature_alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../alarm/alarm_entry_section.dart';
import '../alarm/alarm_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showAlarmEntrySheet([Alarm? alarm]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return BlocProvider(
          create: (_) => AlarmEditCubit(
            context.read<AlarmUseCases>(),
            initialState: alarm != null ? AlarmEditState.initial(alarm) : null,
          ),
          child: BlocConsumer<AlarmEditCubit, AlarmEditState>(
            listener: (context, state) {
              if (state.status == AlarmEditStatus.success) {
                Navigator.of(context).pop();
              } else if (state.status == AlarmEditStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage ?? '저장 실패')),
                );
              }
            },
            builder: (context, state) {
              return AppBottomSheetScaffold(
                title: alarm == null ? '알람 추가' : '알람 수정',
                heightFactor: 0.72,
                action: AppPrimaryButton(
                  label: state.status == AlarmEditStatus.saving ? '저장 중...' : '저장',
                  onPressed: state.status == AlarmEditStatus.saving
                      ? null
                      : () => context.read<AlarmEditCubit>().save(),
                ),
                child: const AlarmEntrySection(),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알람')),
      body: SafeArea(
        child: AlarmScreen(
          onEditAlarm: (alarm) => _showAlarmEntrySheet(alarm),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAlarmEntrySheet,
        tooltip: '알람 추가',
        child: const Icon(Icons.add),
      ),
    );
  }
}
