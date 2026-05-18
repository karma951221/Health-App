import 'package:drift/drift.dart';

class AlarmTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  IntColumn get weekdayMask => integer()();
  DateTimeColumn get oneShotDate => dateTime().nullable()();
  DateTimeColumn get nextScheduledAt => dateTime().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get shakeCount => integer().withDefault(const Constant(20))();
  TextColumn get label => text()();
}
