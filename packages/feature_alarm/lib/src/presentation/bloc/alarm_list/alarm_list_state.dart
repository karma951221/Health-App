import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/alarm.dart';

part 'alarm_list_state.freezed.dart';

enum AlarmListStatus { initial, loading, loaded, failure }

@freezed
class AlarmListState with _$AlarmListState {
  const AlarmListState({
    this.status = AlarmListStatus.initial,
    this.alarms = const [],
    this.errorMessage,
  });

  final AlarmListStatus status;
  final List<Alarm> alarms;
  final String? errorMessage;
}
