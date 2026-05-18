import 'package:app_ui/app_ui.dart';
import 'package:feature_alarm/feature_alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../alarm/alarm_entry_section.dart';
import '../alarm/alarm_ringing_screen.dart';
import '../alarm/alarm_screen.dart';
import '../meal/meal_screen.dart';
import '../workout/workout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime(2026, 5, 17);

  void _moveDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  void _showEntrySheet() {
    if (_selectedIndex == 0) {
      _showAlarmEntrySheet();
    } else {
      _showSimpleEntrySheet();
    }
  }

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

  void _showSimpleEntrySheet() {
    final title = _selectedIndex == 1 ? '운동 기록' : '식단 기록';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AppBottomSheetScaffold(
          title: title,
          action: AppPrimaryButton(
            label: '저장',
            onPressed: () => Navigator.of(context).pop(),
          ),
          child: const Center(child: Text('준비 중입니다.')),
        );
      },
    );
  }

  void _showCalendarPlaceholder() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('달력 선택은 다음 단계에서 연결할 예정이에요.')));
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      AlarmScreen(
        onEditAlarm: (alarm) => _showAlarmEntrySheet(alarm),
        onPreviewRinging: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AlarmRingingScreen(),
            ),
          );
        },
      ),
      WorkoutScreen(
        date: _selectedDate,
        onPreviousDay: () => _moveDate(-1),
        onNextDay: () => _moveDate(1),
        onCalendarTap: _showCalendarPlaceholder,
      ),
      MealScreen(
        date: _selectedDate,
        onPreviousDay: () => _moveDate(-1),
        onNextDay: () => _moveDate(1),
        onCalendarTap: _showCalendarPlaceholder,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Daylog')),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: tabs),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEntrySheet,
        tooltip: '추가',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm),
            label: '알람',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: '운동',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: '식단',
          ),
        ],
      ),
    );
  }
}
