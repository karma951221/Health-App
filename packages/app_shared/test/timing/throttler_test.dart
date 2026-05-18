import 'package:app_shared/src/timing/throttler.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Throttler', () {
    test('first call fires immediately (leading edge)', () {
      fakeAsync((async) {
        final t = Throttler(interval: const Duration(milliseconds: 100));
        var count = 0;

        t.call(() => count++);
        expect(count, 1);
      });
    });

    test('calls within the interval are ignored', () {
      fakeAsync((async) {
        final t = Throttler(interval: const Duration(milliseconds: 100));
        var count = 0;

        t.call(() => count++);
        async.elapse(const Duration(milliseconds: 50));
        t.call(() => count++);
        async.elapse(const Duration(milliseconds: 49));
        t.call(() => count++);
        expect(count, 1);
      });
    });

    test('after the interval elapses, the next call fires', () {
      fakeAsync((async) {
        final t = Throttler(interval: const Duration(milliseconds: 100));
        var count = 0;

        t.call(() => count++);
        async.elapse(const Duration(milliseconds: 100));
        t.call(() => count++);
        expect(count, 2);
      });
    });
  });
}
