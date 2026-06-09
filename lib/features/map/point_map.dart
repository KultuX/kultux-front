import 'package:latlong2/latlong.dart';

class PointMap {
  final int ine;
  final String name;
  final LatLng coordinates;
  final int totalActivities;

  const PointMap({
    required this.ine,
    required this.name,
    required this.coordinates,
    required this.totalActivities,
  });
}