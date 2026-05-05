import 'package:kultux/models/imagen.dart';
class Actividad{
  final int id;
  final String titulo;
  final String categoriaActividad;
  final String imagenPrincipal;
  final String fechaInicio;
  final String localidad;
  final String estado;

  String? descripcion;
  String? telefonoEmpresa;
  String? correoCorporativo;
  String? fechaFin;
  String? horaFin;
  String? horaInicio;
  List<Imagen>? imagenes;

  Actividad._({
    required this.id,
    required this.titulo,
    required this.categoriaActividad,
    required this.imagenPrincipal,
    required this.fechaInicio,
    required this.localidad,
    required this.estado,
    this.horaInicio,
    this.descripcion,
    this.telefonoEmpresa,
    this.correoCorporativo,
    this.fechaFin,
    this.horaFin,
    this.imagenes
  });

  factory Actividad.inicio(Map<String, dynamic> json) {
    return Actividad._(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      categoriaActividad: json['categoriaActividad'] ?? '',
      imagenPrincipal: json['portada'] ?? 'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg',
      fechaInicio: json['fechaInicio'] ?? '',
      localidad: json['localidad'] ?? '',
      estado: json['estado'] ?? ''
    );
  }

  factory Actividad.detalle(Map<String, dynamic> json) {
    return Actividad._(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? 'No disponible',
      localidad: json['localidad'] ?? 'No disponible',
      categoriaActividad: json['categoriaActividad'] ?? 'No disponible',
      imagenPrincipal: json['portada'] ?? 'logo_kultux.png',
      fechaInicio: json['fechaInicio'] ?? 'No disponible',
      horaInicio: json['horaInicio'] ?? 'No disponible',
      descripcion: json['descripcion'] ?? 'No disponible',
      telefonoEmpresa: json['telefonoEmpresa'] ?? 'No disponible',
      correoCorporativo: json['correoEmpresa'] ?? 'No disponible',
      fechaFin: json['fechaFin'] ,
      horaFin: json['horaFin'],
      imagenes: json['imagenes'] != null
          ? (json['imagenes'] as List)
          .map((e) => Imagen.fromJson(e))
          .toList()
          : [],
      estado: json['estado'] ?? ''
    );
  }


}

