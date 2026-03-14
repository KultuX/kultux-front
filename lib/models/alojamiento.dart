class Alojamiento{
  final int id;
  final String nombre;
  final String categoriaAlojamiento;
  final String imagenPrincipal;

  String? telefonoEmpresa;
  String? correoCorporativo;

  Alojamiento._({
    required this.id,
    required this.nombre,
    required this.categoriaAlojamiento,
    required this.imagenPrincipal,
    this.telefonoEmpresa,
    this.correoCorporativo
  });

  factory Alojamiento.destacado(Map<String, dynamic> json){
    return Alojamiento._(
        id: json['id'],
        nombre: json['nombre'],
        categoriaAlojamiento: json['categoriaAlojamiento'],
        imagenPrincipal: json['imagenPrincipal']
    );
  }

  factory Alojamiento.detalle(Map<String, dynamic> json){
    return Alojamiento._(

        id: json['id'],
        nombre: json['nombre'],
        categoriaAlojamiento: json['categoriaAlojamiento'],
        imagenPrincipal: json['imagenPrincipal'],
      telefonoEmpresa: json['telefonoEmpresa'],
      correoCorporativo: json['correoCorporativo'],

    );
  }
}