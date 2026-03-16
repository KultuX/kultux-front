class Restaurante{
  final int id;
  final String nombre;
  final String categoriaRestaurante;
  final String imagenPrincipal;

  String? descripcion;
  String? telefonoEmpresa;
  String? correoCorporativo;
  String? horarioApetura;
  String? localidad;

  Restaurante._({
    required this.id,
    required this.nombre,
    required this.categoriaRestaurante,
    required this.imagenPrincipal,
    this.descripcion,
    this.telefonoEmpresa,
    this.correoCorporativo,
    this.horarioApetura,
    this.localidad
  });

  factory Restaurante.destacado(Map<String, dynamic> json){
    return Restaurante._(
      id: json['id'],
      nombre: json['nombre'],
      categoriaRestaurante: json['categoriaRestaurante'],
      imagenPrincipal: json['imagenPrincipal']
    );
  }

  factory Restaurante.detalle(Map<String, dynamic> json){
    return Restaurante._(
        id: json['id'],
        nombre: json['nombre'],
        categoriaRestaurante: json['categoriaRestaurante'],
        imagenPrincipal: json['imagenPrincipal'],
        descripcion: json['descripcion'],
        telefonoEmpresa: json['telefonoEmpresa'],
        correoCorporativo: json['correoCorporativo'],
        horarioApetura: json['horarioApertura'],
        localidad: json['localidad']
    );
  }
}