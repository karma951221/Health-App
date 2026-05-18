import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/alarm.dart';

part 'alarm_list_event.freezed.dart';

@freezed
sealed class AlarmListEvent with _$AlarmListEvent {
  const factory AlarmListEvent.started() = AlarmListStarted;
  const factory AlarmListEvent.toggled({
    required Alarm alarm,
    required bool enabled,
  }) = AlarmListToggled;
  const factory AlarmListEvent.deleted({
    required int id,
  }) = AlarmListDeleted;
}
