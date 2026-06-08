import 'package:latlong2/latlong.dart';

class PointMap {
  final int ine;
  final String nombre;
  final LatLng coordenadas;
  final int totalActividades;

  const PointMap({
    required this.ine,
    required this.nombre,
    required this.coordenadas,
    required this.totalActividades,
  });
}