import 'package:app_shared/src/date/date_time_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeX', () {
    test('startOfDay zeroes time fields', () {
      final dt = DateTime(2026, 5, 17, 14, 30, 45, 678, 90);
      expect(dt.startOfDay, DateTime(2026, 5, 17));
    });

    test('endOfDay returns last microsecond of the day', () {
      final dt = DateTime(2026, 5, 17, 8);
      expect(dt.endOfDay, DateTime(2026, 5, 17, 23, 59, 59, 999, 999));
    });

    test('isSameDay ignores time fields', () {
      final a = DateTime(2026, 5, 17, 1);
      final b = DateTime(2026, 5, 17, 23, 59);
      final c = DateTime(2026, 5, 18, 0);
      expect(a.isSameDay(b), isTrue);
      expect(a.isSameDay(c), isFalse);
    });
  });
}
