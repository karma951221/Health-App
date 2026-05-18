import 'package:app_shared/src/id/uuid_gen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UuidGen.v4', () {
    test('returns a canonical 36-char string with 4 hyphens', () {
      final id = UuidGen.v4();
      expect(id.length, 36);
      expect(id.split('-').length, 5);
    });

    test('matches RFC 4122 v4 format (version 4, variant 8/9/a/b)', () {
      final id = UuidGen.v4();
      final pattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(pattern.hasMatch(id), isTrue, reason: 'got "$id"');
    });

    test('produces unique values across calls', () {
      final ids = {for (var i = 0; i < 100; i++) UuidGen.v4()};
      expect(ids.length, 100);
    });
  });
}
