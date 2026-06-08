class TimeSlot {
  final String inicio;
  final String fin;

  TimeSlot._({required this.inicio, required this.fin});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot._(inicio: json['inicio'], fin: json['fin']);
  }
}
