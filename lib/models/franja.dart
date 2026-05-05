class Franja{
  final String inicio;
  final String fin;

  Franja._({
    required this.inicio,
    required this.fin
  });

  factory Franja.fromJson(Map<String, dynamic> json){
    return Franja._(
      inicio: json['inicio'],
      fin: json['fin']
    );
  }
}