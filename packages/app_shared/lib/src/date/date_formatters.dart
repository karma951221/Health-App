import 'package:intl/intl.dart';

class DateFormatters {
  const DateFormatters._();

  static final DateFormat _yyyyMMdd = DateFormat('yyyy-MM-dd');
  static final DateFormat _koreanWeekday = DateFormat('E', 'ko_KR');

  static String yyyyMMdd(DateTime dt) => _yyyyMMdd.format(dt);

  static String koreanFull(DateTime dt) =>
      '${_yyyyMMdd.format(dt)} (${_koreanWeekday.format(dt)})';

  static String hourMinute(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  // bit0=월 … bit6=일 (PLAN.md Alarms.weekdayMask 규약)
  static String weekdayMaskKorean(int mask) {
    if (mask == 0) return '일회성';
    if (mask & 0x7F == 0x7F) return '매일';
    if (mask & 0x7F == 0x1F) return '주중';
    if (mask & 0x7F == 0x60) return '주말';

    const labels = ['월', '화', '수', '목', '금', '토', '일'];
    final active = <String>[
      for (var i = 0; i < 7; i++)
        if ((mask >> i) & 1 == 1) labels[i],
    ];
    return active.join('·');
  }
}
