import 'package:flutter/cupertino.dart';
import 'package:kultux/models/imagen.dart';
import 'package:kultux/models/franja.dart';

class Restaurante{
  final int id;
  final String nombre;
  final String categoriaRestaurante;
  String? imagenPrincipal;

  String? descripcion;
  String? telefonoEmpresa;
  String? correoCorporativo;
  Map<String,List<Franja>>? horario;
  String? localidad;
  List<Imagen>? imagenes;
  bool? abierto;
  String? urlReserva;
  String? urlWeb;
  String? direccion;

  Restaurante._({
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
    this.direccion
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
        categoriaRestaurante: json['categoria'],
        descripcion: json['descripcion'],
        telefonoEmpresa: json['telefono'],
        correoCorporativo: json['email'],
        horario: _parseHorario(json['horario']),
        localidad: json['localidad'],
        imagenes: json['imagenes'] != null
            ? (json['imagenes'] as List)
            .map((e) => Imagen.fromJson(e))
            .toList()
            : [],
        abierto: json['abierto'],
        urlReserva: json['urlReserva'],
        urlWeb: json['urlWeb'],
       direccion: json['direccion']
    );
  }

  factory Restaurante.busqueda(Map<String, dynamic> json){
    debugPrint('Abierto API: ${json['abierto']} | Hora local: ${DateTime.now()}');
    return Restaurante._(
      id: json['id'],
      nombre: json['nombre'],
      horario: _parseHorario(json['horario']),
      localidad: json['localidad']['nombre'],
      categoriaRestaurante: json['categoria'],
      imagenPrincipal: json['portada'],
      abierto: json['abierto']
    );
  }

  factory Restaurante.guardado(Map<String, dynamic> json){
    return Restaurante._(
        id:json['id'],
        nombre: json['nombre'],
        imagenPrincipal: json['portada'],
        categoriaRestaurante: json['categoria'],
        localidad: json['localidad'],
        abierto: json['abierto']
    );
  }


  static Map<String, List<Franja>> _parseHorario(Map<String, dynamic> jsonHorario) {
    return jsonHorario.map(
          (dia, franjas) => MapEntry(
        dia,
        (franjas as List)
            .map((f) => Franja.fromJson(f))
            .toList(),
      ),
    );
  }



}