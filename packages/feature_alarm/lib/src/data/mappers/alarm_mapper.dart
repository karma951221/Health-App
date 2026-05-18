import 'package:infra_local_db/infra_local_db.dart';
import '../../domain/entities/alarm.dart';

extension AlarmMapper on AlarmTableData {
  Alarm toEntity() {
    return Alarm(
      id: id,
      hour: hour,
      minute: minute,
      weekdayMask: weekdayMask,
      oneShotDate: oneShotDate,
      nextScheduledAt: nextScheduledAt,
      enabled: enabled,
      shakeCount: shakeCount,
      label: label,
    );
  }
}

extension AlarmEntityMapper on Alarm {
  AlarmTableData toTableData() {
    return AlarmTableData(
      id: id ?? 0, // 0 is temporary for new items
      hour: hour,
      minute: minute,
      weekdayMask: weekdayMask,
      oneShotDate: oneShotDate,
      nextScheduledAt: nextScheduledAt,
      enabled: enabled,
      shakeCount: shakeCount,
      label: label,
    );
  }
}
