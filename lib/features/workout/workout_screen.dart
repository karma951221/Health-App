import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import '../shared/shared_widget.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({
    super.key,
    required this.date,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onCalendarTap,
  });

  final DateTime date;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onCalendarTap;

  static const _items = [
    TimelineItem('07:20', '상체 40분 / 푸시업 5세트'),
    TimelineItem('19:10', '빠르게 걷기 30분'),
  ];

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      header: DateHeader(
        date: date,
        onPreviousDay: onPreviousDay,
        onNextDay: onNextDay,
        onCalendarTap: onCalendarTap,
      ),
      title: '오늘의 운동',
      subtitle: '짧게 남겨도 흐름이 보여요.',
      child: _items.isEmpty
          ? const EmptyState(
              icon: Icons.fitness_center_outlined,
              title: '오늘 기록한 운동이 없어요',
              body: '가볍게 한 줄만 남겨도 충분해요.',
            )
          : Column(
              children: [
                for (final item in _items)
                  RecordCard(
                    leading: const Icon(Icons.fitness_center_outlined),
                    time: item.time,
                    title: item.memo,
                  ),
              ],
            ),
    );
  }
}
