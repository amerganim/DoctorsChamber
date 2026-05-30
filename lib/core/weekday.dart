/// Number of hours after midnight that still belong to the previous day for
/// queue-management purposes. Many doctors run past 12:00 AM (e.g. start at
/// 7 PM and finish at 1–2 AM) and still consider that night part of the
/// same business day. Shifting the rollover by 3 hours means the "day"
/// effectively ends at 03:00 local time.
const _businessDayShiftHours = 3;

DateTime _businessNow() {
  return DateTime.now().subtract(const Duration(hours: _businessDayShiftHours));
}

String formatTime12h(DateTime t) {
  final hour = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
  final minute = t.minute.toString().padLeft(2, '0');
  final period = t.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String todayDateKey() {
  final now = _businessNow();
  return '${now.year.toString().padLeft(4, '0')}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}';
}

String todayWeekday() {
  switch (_businessNow().weekday) {
    case DateTime.saturday:
      return 'Sat';
    case DateTime.sunday:
      return 'Sun';
    case DateTime.monday:
      return 'Mon';
    case DateTime.tuesday:
      return 'Tue';
    case DateTime.wednesday:
      return 'Wed';
    case DateTime.thursday:
      return 'Thu';
    case DateTime.friday:
      return 'Fri';
  }
  return '';
}
