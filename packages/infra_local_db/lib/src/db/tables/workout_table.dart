import 'package:drift/drift.dart';

class WorkoutTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get loggedAt => dateTime()();
  TextColumn get memo => text()();
}
