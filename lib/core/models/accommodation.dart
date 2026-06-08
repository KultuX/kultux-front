import 'package:kultux/core/models/image.dart';

class Accommodation {
  final int id;
  final String nombre;
  final String categoriaAlojamiento;
  String? imagenPrincipal;

  String? localidad;
  String? telefonoEmpresa;
  String? correoCorporativo;
  List<Image>? imagenes;
  String? descripcion;

  String? urlReserva;
  String? urlWeb;

  String? direccion;

  Accommodation._({
    required this.id,
    required this.nombre,
    required this.categoriaAlojamiento,
    required this.imagenPrincipal,
    this.telefonoEmpresa,
    this.correoCorporativo,
    this.localidad,
    this.imagenes,
    this.urlReserva,
    this.urlWeb,
    this.descripcion,
    this.direccion,
  });

  factory Accommodation.trending(Map<String, dynamic> json) {
    return Accommodation._(
      id: json['id'],
      nombre: json['nombre'],
      categoriaAlojamiento: json['categoriaAlojamiento'],
      imagenPrincipal:
          json['portada'] ??
          'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg',
    );
  }

  factory Accommodation.search(Map<String, dynamic> json) {
    return Accommodation._(
      id: json['idAlojamiento'],
      nombre: json['nombre'],
      categoriaAlojamiento: json['categoriaAlojamiento'],
      localidad: json['localidad'],
      imagenPrincipal:
          json['portada'] ??
          'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg',
    );
  }

  factory Accommodation.detail(Map<String, dynamic> json) {
    return Accommodation._(
      id: json['id'],
      nombre: json['nombre'],
      categoriaAlojamiento: json['categoriaAlojamiento'],
      imagenPrincipal: json['portada'],
      telefonoEmpresa: json['telefono'],
      correoCorporativo: json['email'],
      localidad: json['localidad'],
      imagenes: json['imagenes'] != null
          ? (json['imagenes'] as List).map((e) => Image.fromJson(e)).toList()
          : null,
      urlReserva: json['urlReserva'],
      urlWeb: json['urlWeb'],
      descripcion: json['descripcion'],
      direccion: json['direccion'],
    );
  }

  factory Accommodation.saved(Map<String, dynamic> json) {
    return Accommodation._(
      id: json['idAlojamiento'],
      nombre: json['nombre'],
      imagenPrincipal: json['portada'],
      categoriaAlojamiento: json['categoriaAlojamiento'],
      localidad: json['localidad'],
    );
  }
}
