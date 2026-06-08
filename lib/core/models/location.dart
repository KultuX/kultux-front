class Location {
  final String nombre;
  final int ine;

  final double? lat;
  final double? lon;

  Location({required this.nombre, required this.ine, this.lat, this.lon});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      nombre: json['nombre'],
      ine: json['ine'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}
