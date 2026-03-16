class Actividad{
  final int id;
  final String titulo;
  final String categoriaActividad;
  final String imagenPrincipal;
  final String fechaInicio;
  final String localidad;

  String? descripcion;
  String? telefonoEmpresa;
  String? correoCorporativo;
  String? fechaFin;

  Actividad._({
    required this.id,
    required this.titulo,
    required this.categoriaActividad,
    required this.imagenPrincipal,
    required this.fechaInicio,
    required this.localidad,
    this.descripcion,
    this.telefonoEmpresa,
    this.correoCorporativo,
    this.fechaFin,
  });

  factory Actividad.inicio(Map<String, dynamic> json) {
    return Actividad._(
      id: json['id'],
      titulo: json['titulo'],
      categoriaActividad: json['categoriaActividad'],
      imagenPrincipal: json['imagenPrincipal'],
      fechaInicio: json['fechaInicio'],
      localidad: json['localidad']
    );
  }

  factory Actividad.detalle(Map<String, dynamic> json) {
    return Actividad._(
      id: json['id'],
      titulo: json['titulo'],
      localidad: json['localidad'],
      categoriaActividad: json['categoriaActividad'],
      imagenPrincipal: json['imagenPrincipal'],
      fechaInicio: json['fechaInicio'],
      descripcion: json['descripcion'],
      telefonoEmpresa: json['telefonoEmpresa'],
      correoCorporativo: json['correoEmpresa'],
      fechaFin: json['fechaFin'],
    );
  }


}