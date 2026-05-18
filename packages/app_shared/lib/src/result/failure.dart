sealed class Failure {
  const Failure(this.message, [this.cause]);

  final String message;
  final Object? cause;

  static Failure database({required String message, Object? cause}) =>
      DatabaseFailure(message, cause);

  static Failure notFound({required String message, Object? cause}) =>
      NotFoundFailure(message, cause);

  static Failure unknown({required String message, Object? cause}) =>
      UnknownFailure(message, cause);

  @override
  String toString() => '$runtimeType($message)';
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.cause]);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.cause]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.cause]);
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.cause]);
}
