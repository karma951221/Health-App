import 'package:app_shared/src/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLogger', () {
    late List<String> captured;
    late DebugPrintCallback original;

    setUp(() {
      captured = [];
      original = debugPrint;
      debugPrint = (String? msg, {int? wrapWidth}) {
        if (msg != null) captured.add(msg);
      };
    });

    tearDown(() => debugPrint = original);

    test('d/i/w/e emit prefixed messages in debug mode', () {
      AppLogger.d('debug-msg');
      AppLogger.i('info-msg');
      AppLogger.w('warn-msg');
      AppLogger.e('error-msg');

      expect(captured.length, 4);
      expect(captured[0], contains('debug-msg'));
      expect(captured[0], contains('D'));
      expect(captured[1], contains('I'));
      expect(captured[2], contains('W'));
      expect(captured[3], contains('error-msg'));
    });

    test('e includes error object and stack when provided', () {
      final stack = StackTrace.current;
      AppLogger.e('boom', error: 'cause-obj', stack: stack);

      final joined = captured.join('\n');
      expect(joined, contains('boom'));
      expect(joined, contains('cause-obj'));
    });
  });
}
