import 'package:kultux/models/franja.dart';

class Horario{
  List<int> dias;
  List<Franja> franjas;

  Horario._({
    required this.dias,
    required this.franjas
  });

  factory Horario.fromJson(Map<String, dynamic> json){
    return Horario._(
      dias: List<int>.from(json['dias'] ?? []),
      franjas: (json['franjas'] as List)
          .map((e) => Franja.fromJson(e))
          .toList(),
    );
  }

}