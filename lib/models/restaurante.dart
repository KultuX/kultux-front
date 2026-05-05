import 'package:kultux/models/imagen.dart';
import 'package:kultux/models/horario.dart';
class Restaurante{
  final int id;
  final String nombre;
  final String categoriaRestaurante;
  final String imagenPrincipal;

  String? descripcion;
  String? telefonoEmpresa;
  String? correoCorporativo;
  Horario? horario;
  String? localidad;
  List<Imagen>? imagenes;
  bool? abierto;

  Restaurante._({
    required this.id,
    required this.nombre,
    required this.categoriaRestaurante,
    required this.imagenPrincipal,
    this.descripcion,
    this.telefonoEmpresa,
    this.correoCorporativo,
    this.horario,
    this.localidad,
    this.imagenes,
    this.abierto
  });

  factory Restaurante.destacado(Map<String, dynamic> json){
    return Restaurante._(
      id: json['id'],
      nombre: json['nombre'],
      categoriaRestaurante: json['categoriaRestaurante'],
      imagenPrincipal: json['portada'] ?? 'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg'
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
        horario: Horario.fromJson(json['horario']),
        localidad: json['localidad'],
        imagenes: json['imagenes'],
        abierto: json['abierto'] // -> añadir campo en spring boot
    );
  }

  factory Restaurante.busqueda(Map<String, dynamic> json){
    return Restaurante._(
      id: json['id'],
      nombre: json['nombre'],
      horario: Horario.fromJson(json['horario']),
      localidad: json['localidad']['nombre'],
      categoriaRestaurante: json['categoria'],
      imagenPrincipal: json['portada'],
      abierto: json['abierto']
    );
  }
}