import 'package:flutter/material.dart';

const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

class DateHeader extends StatelessWidget {
  const DateHeader({
    super.key,
    required this.date,
    required this.onPreviousDay,
    required this.onNextDay,
    this.onCalendarTap,
  });

  final DateTime date;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback? onCalendarTap;

  String _format(DateTime d) {
    final weekday = _weekdays[d.weekday - 1];
    return '${d.year}년 ${d.month}월 ${d.day}일 $weekday';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          onPressed: onPreviousDay,
          icon: const Icon(Icons.chevron_left),
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: GestureDetector(
            onTap: onCalendarTap,
            child: Text(
              _format(date),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        IconButton(
          onPressed: onNextDay,
          icon: const Icon(Icons.chevron_right),
          visualDensity: VisualDensity.compact,
        ),
        if (onCalendarTap != null)
          IconButton(
            onPressed: onCalendarTap,
            icon: const Icon(Icons.calendar_month_outlined),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
