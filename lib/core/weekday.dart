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
