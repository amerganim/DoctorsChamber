String formatTime12h(DateTime t) {
  final hour = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
  final minute = t.minute.toString().padLeft(2, '0');
  final period = t.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String todayDateKey() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}';
}

String todayWeekday() {
  switch (DateTime.now().weekday) {
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
