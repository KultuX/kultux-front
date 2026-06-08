class Location {
  final String name;
  final int ine;

  final double? lat;
  final double? lon;

  Location({required this.name, required this.ine, this.lat, this.lon});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['nombre'],
      ine: json['ine'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}
