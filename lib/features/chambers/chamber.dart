enum ChamberBookingMode {
  fullDigital,
  hybridWithCap,
  queueOnly;

  String get displayName => switch (this) {
        ChamberBookingMode.fullDigital => 'Full digital',
        ChamberBookingMode.hybridWithCap => 'Hybrid with daily cap',
        ChamberBookingMode.queueOnly => 'Queue only (walk-in)',
      };

  String get description => switch (this) {
        ChamberBookingMode.fullDigital =>
          'All bookings via the app. No walk-ins.',
        ChamberBookingMode.hybridWithCap =>
          'Daily cap on app bookings. Rest of the queue is walk-in.',
        ChamberBookingMode.queueOnly =>
          'Walk-ins only. Patients see the live queue but cannot book in advance.',
      };

  static ChamberBookingMode fromString(String? s) {
    return ChamberBookingMode.values.firstWhere(
      (e) => e.name == s,
      orElse: () => ChamberBookingMode.fullDigital,
    );
  }
}

const kWeekdays = <String>['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

class Chamber {
  const Chamber({
    required this.id,
    required this.doctorId,
    required this.name,
    required this.address,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.consultationFee,
    required this.bookingMode,
    this.dailyAppBookingCap,
  });

  final String id;
  final String doctorId;
  final String name;
  final String address;
  final List<String> days;
  final String startTime;
  final String endTime;
  final int consultationFee;
  final ChamberBookingMode bookingMode;
  final int? dailyAppBookingCap;

  Map<String, dynamic> toMap() => {
        'doctorId': doctorId,
        'name': name,
        'address': address,
        'days': days,
        'startTime': startTime,
        'endTime': endTime,
        'consultationFee': consultationFee,
        'bookingMode': bookingMode.name,
        'dailyAppBookingCap': dailyAppBookingCap,
      };

  factory Chamber.fromMap(String id, Map<String, dynamic> map) {
    return Chamber(
      id: id,
      doctorId: (map['doctorId'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      address: (map['address'] as String?) ?? '',
      days: List<String>.from((map['days'] as List?) ?? const []),
      startTime: (map['startTime'] as String?) ?? '17:00',
      endTime: (map['endTime'] as String?) ?? '21:00',
      consultationFee: (map['consultationFee'] as num?)?.toInt() ?? 0,
      bookingMode: ChamberBookingMode.fromString(map['bookingMode'] as String?),
      dailyAppBookingCap: (map['dailyAppBookingCap'] as num?)?.toInt(),
    );
  }
}
