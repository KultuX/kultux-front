class TimeSlot {
  final String start;
  final String end;

  TimeSlot._({required this.start, required this.end});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot._(start: json['inicio'], end: json['fin']);
  }
}
