
import 'package:kultux/models/actividad.dart';
import 'package:kultux/models/alojamiento.dart';
import 'package:kultux/models/restaurante.dart';
class Pages<T> {
  final List<T> contenido;
  final int numero;
  final int totalPaginas;

  Pages._({
    required this.contenido,
    required this.numero,
    required this.totalPaginas,
  });

  factory Pages.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json) fromJsonT,
      ) {
    final List contentRaw = json['content'] ?? [];

    return Pages._(
      contenido: contentRaw
          .map((e) => fromJsonT(e))
          .toList(),
      numero: json['number'],
      totalPaginas: json['totalPages'],
    );
  }
}