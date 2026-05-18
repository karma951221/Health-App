import 'package:app_shared/src/date/date_formatters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko_KR', null);
  });

  group('DateFormatters', () {
    test('yyyyMMdd formats with zero padding', () {
      expect(
        DateFormatters.yyyyMMdd(DateTime(2026, 5, 7)),
        '2026-05-07',
      );
    });

    test('koreanFull renders "YYYY-MM-DD (요일)" in Korean', () {
      // 2026-05-17 is a Sunday
      expect(
        DateFormatters.koreanFull(DateTime(2026, 5, 17)),
        '2026-05-17 (일)',
      );
    });

    test('hourMinute pads hour and minute to two digits', () {
      expect(DateFormatters.hourMinute(7, 5), '07:05');
      expect(DateFormatters.hourMinute(23, 59), '23:59');
    });

    test('weekdayMaskKorean lists active weekdays in 월-일 order', () {
      // bit0 = 월 ... bit6 = 일
      const monWedFri = 1 | 1 << 2 | 1 << 4;
      expect(DateFormatters.weekdayMaskKorean(monWedFri), '월·수·금');
    });

    test('weekdayMaskKorean returns "매일" when all 7 bits set', () {
      expect(DateFormatters.weekdayMaskKorean(0x7F), '매일');
    });

    test('weekdayMaskKorean returns "일회성" when mask is 0', () {
      expect(DateFormatters.weekdayMaskKorean(0), '일회성');
    });

    test('weekdayMaskKorean returns "주말" when only Sat+Sun', () {
      const satSun = 1 << 5 | 1 << 6;
      expect(DateFormatters.weekdayMaskKorean(satSun), '주말');
    });

    test('weekdayMaskKorean returns "주중" when Mon-Fri only', () {
      const monFri = 0x1F;
      expect(DateFormatters.weekdayMaskKorean(monFri), '주중');
    });
  });
}
