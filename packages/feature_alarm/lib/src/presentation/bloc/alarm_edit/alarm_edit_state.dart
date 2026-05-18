import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/alarm.dart';

part 'alarm_edit_state.freezed.dart';

enum AlarmEditStatus { initial, saving, success, failure }

@freezed
class AlarmEditState with _$AlarmEditState {
  const AlarmEditState({
    required this.alarm,
    this.status = AlarmEditStatus.initial,
    this.errorMessage,
  });

  final Alarm alarm;
  final AlarmEditStatus status;
  final String? errorMessage;

  factory AlarmEditState.initial([Alarm? alarm]) => AlarmEditState(
        alarm: alarm ??
            const Alarm(
              id: null,
              hour: 7,
              minute: 0,
              weekdayMask: 0,
              oneShotDate: null,
              nextScheduledAt: null,
              enabled: true,
              shakeCount: 20,
              label: '',
            ),
      );
}
