class Localidad{
  final String nombre;
  final int ine;

  Localidad({required this.nombre, required this.ine});

  factory Localidad.fromJson(Map<String, dynamic> json){
    return Localidad(
      nombre: json['nombre'],
        ine: json['ine']
    );
  }

}