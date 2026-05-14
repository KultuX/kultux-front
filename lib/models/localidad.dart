class Localidad{
  final String nombre;
  final int ine;

  final double? lat;
  final double? lon;

  Localidad({required this.nombre, required this.ine, this.lat, this.lon});

  factory Localidad.fromJson(Map<String, dynamic> json){
    return Localidad(
      nombre: json['nombre'],
      ine: json['ine'],
      lat: json['lat'],
      lon: json['lon']
    );
  }

}