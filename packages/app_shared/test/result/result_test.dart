import 'package:app_shared/src/result/failure.dart';
import 'package:app_shared/src/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok carries a value, Err carries a failure', () {
      const Result<int, Failure> ok = Ok(42);
      const Result<int, Failure> err = Err(UnknownFailure('boom'));

      expect((ok as Ok<int, Failure>).value, 42);
      expect((err as Err<int, Failure>).failure, isA<UnknownFailure>());
    });

    test('switch pattern matching exhaustively handles both branches', () {
      String describe(Result<int, Failure> r) => switch (r) {
            Ok(:final value) => 'ok:$value',
            Err(:final failure) => 'err:${failure.message}',
          };

      expect(describe(const Ok(7)), 'ok:7');
      expect(describe(const Err(DatabaseFailure('disk full'))), 'err:disk full');
    });

    test('fold reduces to a single value', () {
      const Result<int, Failure> ok = Ok(10);
      const Result<int, Failure> err = Err(StorageFailure('io'));

      expect(
        ok.fold(onOk: (v) => v + 1, onErr: (_) => -1),
        11,
      );
      expect(
        err.fold(onOk: (v) => v + 1, onErr: (f) => -f.message.length),
        -2,
      );
    });

    test('isOk / isErr report the variant', () {
      const Result<int, Failure> ok = Ok(1);
      const Result<int, Failure> err = Err(UnknownFailure('x'));
      expect(ok.isOk, isTrue);
      expect(ok.isErr, isFalse);
      expect(err.isOk, isFalse);
      expect(err.isErr, isTrue);
    });
  });

  group('Failure', () {
    test('subclasses expose message and optional cause', () {
      const f = DatabaseFailure('locked', 'PRAGMA');
      expect(f.message, 'locked');
      expect(f.cause, 'PRAGMA');
    });

    test('toString includes class name and message', () {
      const f = StorageFailure('missing file');
      expect(f.toString(), contains('StorageFailure'));
      expect(f.toString(), contains('missing file'));
    });
  });
}
