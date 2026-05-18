import 'failure.dart';

sealed class Result<T, F extends Failure> {
  const Result();

  static Result<T, F> success<T, F extends Failure>(T value) => Ok(value);
  static Result<T, F> failure<T, F extends Failure>(F failure) => Err(failure);

  bool get isOk => this is Ok<T, F>;
  bool get isErr => this is Err<T, F>;

  R fold<R>({
    required R Function(T value) onOk,
    required R Function(F failure) onErr,
  }) =>
      switch (this) {
        Ok<T, F>(:final value) => onOk(value),
        Err<T, F>(:final failure) => onErr(failure),
      };

  Result<U, F> map<U>(U Function(T value) transform) => switch (this) {
        Ok<T, F>(:final value) => Ok(transform(value)),
        Err<T, F>(:final failure) => Err(failure),
      };

  void when({
    required void Function(T value) success,
    required void Function(F failure) failure,
  }) {
    if (this is Ok<T, F>) {
      success((this as Ok<T, F>).value);
    } else {
      failure((this as Err<T, F>).failure);
    }
  }
}

final class Ok<T, F extends Failure> extends Result<T, F> {
  const Ok(this.value);
  final T value;
}

final class Err<T, F extends Failure> extends Result<T, F> {
  const Err(this.failure);
  final F failure;
}
