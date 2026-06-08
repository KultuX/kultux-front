class ActivityTotal {
  final int? ine;
  final int? total;

  ActivityTotal._({this.ine, this.total});
  factory ActivityTotal.fromJson(Map<String, dynamic> json) {
    return ActivityTotal._(ine: json['ine'] ?? 0, total: json['total'] ?? 0);
  }
}
