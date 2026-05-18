import 'package:drift/drift.dart';

class MealTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get loggedAt => dateTime()();
  TextColumn get memo => text()();
  TextColumn get photoPath => text().nullable()();
}
