import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import '../shared/shared_widget.dart';
import 'meal_widget.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({
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
    TimelineItem('08:10', '아침: 그릭요거트, 바나나'),
    TimelineItem('12:40', '점심: 닭가슴살 샐러드'),
    TimelineItem('18:30', '저녁: 현미밥, 계란, 김치'),
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
      title: '오늘의 식단',
      subtitle: '사진과 메모로 하루의 식사를 훑어봐요.',
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++)
            RecordCard(
              leading: MealThumb(index: i),
              time: _items[i].time,
              title: _items[i].memo,
            ),
        ],
      ),
    );
  }
}
