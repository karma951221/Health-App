class AlarmItem {
  const AlarmItem(
    this.id,
    this.time,
    this.label,
    this.weekdays,
    this.shakeCount,
  );

  final int id;
  final String time;
  final String label;
  final String weekdays;
  final int shakeCount;
}
