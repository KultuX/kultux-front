import 'package:kultux/core/models/image.dart';
import 'package:kultux/core/models/time_slot.dart';

class Restaurant {
  final int id;
  final String nombre;
  final String categoriaRestaurante;
  String? imagenPrincipal;

  String? descripcion;
  String? telefonoEmpresa;
  String? correoCorporativo;
  Map<String, List<TimeSlot>>? horario;
  String? localidad;
  List<Image>? imagenes;
  bool? abierto;
  String? urlReserva;
  String? urlWeb;
  String? direccion;

  Restaurant._({
    required this.id,
    required this.nombre,
    required this.categoriaRestaurante,
    this.imagenPrincipal,
    this.descripcion,
    this.telefonoEmpresa,
    this.correoCorporativo,
    this.horario,
    this.localidad,
    this.imagenes,
    this.abierto,
    this.urlReserva,
    this.urlWeb,
    this.direccion,
  });

  factory Restaurant.trending(Map<String, dynamic> json) {
    return Restaurant._(
      id: json['id'],
      nombre: json['nombre'],
      categoriaRestaurante: json['categoriaRestaurante'],
      imagenPrincipal:
          json['portada'] ??
          'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg',
    );
  }

  factory Restaurant.detail(Map<String, dynamic> json) {
    return Restaurant._(
      id: json['id'],
      nombre: json['nombre'],
      categoriaRestaurante: json['categoria'],
      descripcion: json['descripcion'],
      telefonoEmpresa: json['telefono'],
      correoCorporativo: json['email'],
      horario: _parseHorario(json['horario']),
      localidad: json['localidad'],
      imagenes: json['imagenes'] != null
          ? (json['imagenes'] as List).map((e) => Image.fromJson(e)).toList()
          : [],
      abierto: json['abierto'],
      urlReserva: json['urlReserva'],
      urlWeb: json['urlWeb'],
      direccion: json['direccion'],
    );
  }

  factory Restaurant.search(Map<String, dynamic> json) {
    return Restaurant._(
      id: json['id'],
      nombre: json['nombre'],
      horario: _parseHorario(json['horario']),
      localidad: json['localidad'],
      categoriaRestaurante: json['categoria'],
      imagenPrincipal: json['portada'],
      abierto: json['abierto'],
    );
  }

  factory Restaurant.saved(Map<String, dynamic> json) {
    return Restaurant._(
      id: json['id'],
      nombre: json['nombre'],
      imagenPrincipal: json['portada'],
      categoriaRestaurante: json['categoria'],
      localidad: json['localidad'],
      abierto: json['abierto'],
    );
  }

  static Map<String, List<TimeSlot>> _parseHorario(
    Map<String, dynamic> jsonHorario,
  ) {
    return jsonHorario.map(
      (dia, franjas) => MapEntry(
        dia,
        (franjas as List).map((f) => TimeSlot.fromJson(f)).toList(),
      ),
    );
  }
}
