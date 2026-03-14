class Actividad{
  final int id;
  final String titulo;
  final String categoriaActividad;
  final String imagenPrincipal;
  final String fechaInicio;

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
    );
  }

  factory Actividad.detalle(Map<String, dynamic> json) {
    return Actividad._(
      id: json['id'],
      titulo: json['titulo'],
      categoriaActividad: json['categoriaActividad'],
      imagenPrincipal: json['imagenPrincipal'],
      fechaInicio: json['fechaInicio'],
      descripcion: json['descripcion'],
      telefonoEmpresa: json['telefonoEmpresa'],
      correoCorporativo: json['correoCorporativo'],
      fechaFin: json['fechaFin'],
    );
  }


}