class Localidad{
  final String nombre;

  Localidad({required this.nombre});

  factory Localidad.fromJson(Map<String, dynamic> json){
    return Localidad(
      nombre: json['nombre']
    );
  }
}