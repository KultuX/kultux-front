class ActividadTotal{
  final int? ine;
  final int? total;

  ActividadTotal._({this.ine, this.total});
  factory ActividadTotal.fromJson(Map<String, dynamic> json){
    return ActividadTotal._(
        ine: json['ine'] ?? 0,
        total: json['total'] ?? 0
    );
  }

}