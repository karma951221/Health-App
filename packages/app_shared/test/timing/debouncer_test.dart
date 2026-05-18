import 'package:app_shared/src/timing/debouncer.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debouncer', () {
    test('runs action once after the delay elapses', () {
      fakeAsync((async) {
        final d = Debouncer(delay: const Duration(milliseconds: 200));
        var count = 0;

        d.call(() => count++);
        async.elapse(const Duration(milliseconds: 199));
        expect(count, 0);
        async.elapse(const Duration(milliseconds: 1));
        expect(count, 1);
      });
    });

    test('rapid calls collapse into a single trailing invocation', () {
      fakeAsync((async) {
        final d = Debouncer(delay: const Duration(milliseconds: 100));
        var count = 0;

        for (var i = 0; i < 5; i++) {
          d.call(() => count++);
          async.elapse(const Duration(milliseconds: 50));
        }
        async.elapse(const Duration(milliseconds: 100));
        expect(count, 1);
      });
    });

    test('cancel prevents pending invocation', () {
      fakeAsync((async) {
        final d = Debouncer(delay: const Duration(milliseconds: 100));
        var count = 0;

        d.call(() => count++);
        async.elapse(const Duration(milliseconds: 50));
        d.cancel();
        async.elapse(const Duration(milliseconds: 200));
        expect(count, 0);
      });
    });

    test('dispose cancels and prevents further calls from scheduling', () {
      fakeAsync((async) {
        final d = Debouncer(delay: const Duration(milliseconds: 100));
        var count = 0;

        d.call(() => count++);
        d.dispose();
        async.elapse(const Duration(milliseconds: 200));
        expect(count, 0);
      });
    });
  });
}
