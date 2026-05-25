import '../entities/alarm.dart';

extension AlarmScheduleExtension on Alarm {
  /// 꺼진 알람은 예정 시각이 없으므로 null, 켜진 알람은 다음 울림 시각으로 갱신하여 반환합니다.
  Alarm withNextSchedule(DateTime from) {
    if (!enabled) {
      return copyWith(nextScheduledAt: null); // disabled clears schedule
    }
    return copyWith(nextScheduledAt: nextOccurrence(from));
  }

  DateTime nextOccurrence(DateTime from) {
    // 요일이 지정되지 않았다면 1회성 알람 처리
    if (weekdayMask & 0x7F == 0) {
      final today = DateTime(from.year, from.month, from.day, hour, minute);
      return today.isAfter(from) ? today : today.add(const Duration(days: 1));
    }

    // 반복 알람 처리
    final selectedDays = weekdayMask & 0x7F;
    for (var dayOffset = 0; dayOffset <= 7; dayOffset += 1) {
      final date = DateTime(from.year, from.month, from.day).add(Duration(days: dayOffset));
      final bit = 1 << (date.weekday - DateTime.monday);
      
      if ((selectedDays & bit) == 0) continue;

      final candidate = DateTime(date.year, date.month, date.day, hour, minute);
      if (candidate.isAfter(from)) return candidate;
    }

    throw StateError('Unable to calculate next alarm occurrence.');
  }
}
