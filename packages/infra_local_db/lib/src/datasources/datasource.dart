import 'package:app_shared/app_shared.dart';

abstract interface class DataSource<T> {
  Stream<List<T>> watchAll();

  Future<Result<T, Failure>> findById(int id);

  Future<Result<T, Failure>> save(T item);

  Future<Result<T, Failure>> update(T item);

  Future<Result<void, Failure>> deleteById(int id);
}
