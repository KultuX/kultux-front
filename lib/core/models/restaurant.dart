import 'package:kultux/core/models/image.dart';
import 'package:kultux/core/models/time_slot.dart';

class Restaurant {
  final int id;
  final String name;
  final String restaurantCategory;
  String? coverImage;

  String? description;
  String? companyPhone;
  String? businessEmail;
  Map<String, List<TimeSlot>>? schedule;
  String? location;
  List<Image>? images;
  bool? isOpen;
  String? bookingUrl;
  String? webUrl;
  String? address;

  Restaurant._({
    required this.id,
    required this.name,
    required this.restaurantCategory,
    this.coverImage,
    this.description,
    this.companyPhone,
    this.businessEmail,
    this.schedule,
    this.location,
    this.images,
    this.isOpen,
    this.bookingUrl,
    this.webUrl,
    this.address,
  });

  factory Restaurant.trending(Map<String, dynamic> json) {
    return Restaurant._(
      id: json['id'],
      name: json['nombre'],
      restaurantCategory: json['categoriaRestaurante'],
      coverImage:
          json['portada'] ??
          'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg',
    );
  }

  factory Restaurant.detail(Map<String, dynamic> json) {
    return Restaurant._(
      id: json['id'],
      name: json['nombre'],
      restaurantCategory: json['categoria'],
      description: json['descripcion'],
      companyPhone: json['telefono'],
      businessEmail: json['email'],
      schedule: _parseHorario(json['horario']),
      location: json['localidad'],
      images: json['imagenes'] != null
          ? (json['imagenes'] as List).map((e) => Image.fromJson(e)).toList()
          : [],
      isOpen: json['abierto'],
      bookingUrl: json['urlReserva'],
      webUrl: json['urlWeb'],
      address: json['direccion'],
    );
  }

  factory Restaurant.search(Map<String, dynamic> json) {
    return Restaurant._(
      id: json['id'],
      name: json['nombre'],
      schedule: _parseHorario(json['horario']),
      location: json['localidad'],
      restaurantCategory: json['categoria'],
      coverImage: json['portada'],
      isOpen: json['abierto'],
    );
  }

  factory Restaurant.saved(Map<String, dynamic> json) {
    return Restaurant._(
      id: json['id'],
      name: json['nombre'],
      coverImage: json['portada'],
      restaurantCategory: json['categoria'],
      location: json['localidad'],
      isOpen: json['abierto'],
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
