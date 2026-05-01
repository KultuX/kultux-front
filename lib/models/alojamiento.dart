import 'package:kultux/models/imagen.dart';
class Alojamiento{
  final int id;
  final String nombre;
  final String categoriaAlojamiento;
  final String imagenPrincipal;

  String? localidad;
  String? telefonoEmpresa;
  String? correoCorporativo;
  List<Imagen>? imagenes;

  Alojamiento._({
    required this.id,
    required this.nombre,
    required this.categoriaAlojamiento,
    required this.imagenPrincipal,
    this.telefonoEmpresa,
    this.correoCorporativo,
    this.localidad,
    this.imagenes
  });

  factory Alojamiento.destacado(Map<String, dynamic> json){
    return Alojamiento._(
        id: json['id'],
        nombre: json['nombre'],
        categoriaAlojamiento: json['categoriaAlojamiento'],
        imagenPrincipal: json['portada'] ?? 'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg',
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
        localidad: json['localidad'],
        imagenes: json['imagenes']

    );
  }
}