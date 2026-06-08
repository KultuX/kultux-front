import 'package:kultux/core/models/image.dart';

class Activity {
  final int id;
  final String titulo;
  final String? categoriaActividad;
  final String imagenPrincipal;
  final String fechaInicio;
  final String? localidad;
  final String? estado;

  String? descripcion;
  String? telefonoEmpresa;
  String? correoCorporativo;
  String? fechaFin;
  String? horaFin;
  String? horaInicio;
  List<Image>? imagenes;
  String? urlCompra;
  String? urlWeb;
  String? direccion;
  String? nombreEmpresa;
  String? logotipoEmpresa;
  double? precio;
  int? aforoMaximo;

  Activity._({
    required this.id,
    required this.titulo,
    this.categoriaActividad,
    required this.imagenPrincipal,
    required this.fechaInicio,
    this.localidad,
    this.estado,
    this.horaInicio,
    this.descripcion,
    this.telefonoEmpresa,
    this.correoCorporativo,
    this.fechaFin,
    this.horaFin,
    this.imagenes,
    this.urlCompra,
    this.urlWeb,
    this.direccion,
    this.nombreEmpresa,
    this.logotipoEmpresa,
    this.precio,
    this.aforoMaximo
  });

  factory Activity.trending(Map<String, dynamic> json) {
    return Activity._(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      categoriaActividad: json['categoriaActividad'] ?? '',
      imagenPrincipal:
          json['portada'] ?? '',
        fechaInicio: json['fechaInicio'] ?? '',
      localidad: json['localidad'] ?? '',
      estado: json['estado'],
      fechaFin: json['fechaFin'] ?? ''
    );
  }

  factory Activity.search(Map<String, dynamic> json) {
    return Activity._(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      categoriaActividad: json['categoria'] ?? '',
      imagenPrincipal:
          json['portada'] ??
          'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg',
      fechaInicio: json['fechaInicio'] ?? '',
      horaInicio: json['horaInicio'],
      localidad: json['localidad'] ?? '',
      estado: json['estado'],
      fechaFin: json['fechaFin'] ?? ''
    );
  }

  factory Activity.detail(Map<String, dynamic> json) {
    return Activity._(
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
      fechaFin: json['fechaFin'],
      horaFin: json['horaFin'],
      imagenes: json['imagenes'] != null
          ? (json['imagenes'] as List).map((e) => Image.fromJson(e)).toList()
          : [],
      estado: json['estado'] ,
      urlCompra: json['urlCompra'],
      urlWeb: json['urlWeb'],
      direccion: json['direccion'],
      nombreEmpresa: json['nombreEmpresa'],
      logotipoEmpresa: json['logotipoUrl'],
      precio: json['precio'],
      aforoMaximo: json['aforoMaximo']
    );
  }

  factory Activity.saved(Map<String, dynamic> json) {
    return Activity._(
      id: json['idActividad'],
      titulo: json['titulo'],
      fechaInicio: json['fechaInicio'],
      horaInicio: json['horaInicio'],
      imagenPrincipal: json['portada'],
      categoriaActividad: json['categoria'],
      localidad: json['localidad'],
      fechaFin: json['fechaFin'],
      estado: json['estado']
    );
  }
}
