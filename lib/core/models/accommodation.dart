import 'package:kultux/core/models/image.dart';

class Accommodation {
  final int id;
  final String name;
  final String accommodationCategory;
  String? coverImage;

  String? location;
  String? companyPhone;
  String? businessEmail;
  List<Image>? images;
  String? description;

  String? bookingUrl;
  String? webUrl;

  String? address;

  Accommodation._({
    required this.id,
    required this.name,
    required this.accommodationCategory,
    required this.coverImage,
    this.companyPhone,
    this.businessEmail,
    this.location,
    this.images,
    this.bookingUrl,
    this.webUrl,
    this.description,
    this.address,
  });

  factory Accommodation.trending(Map<String, dynamic> json) {
    return Accommodation._(
      id: json['id'],
      name: json['nombre'],
      accommodationCategory: json['categoriaAlojamiento'],
      coverImage:
          json['portada'] ??
          'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg',
    );
  }

  factory Accommodation.search(Map<String, dynamic> json) {
    return Accommodation._(
      id: json['idAlojamiento'],
      name: json['nombre'],
      accommodationCategory: json['categoriaAlojamiento'],
      location: json['localidad'],
      coverImage:
          json['portada'] ??
          'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg',
    );
  }

  factory Accommodation.detail(Map<String, dynamic> json) {
    return Accommodation._(
      id: json['id'],
      name: json['nombre'],
      accommodationCategory: json['categoriaAlojamiento'],
      coverImage: json['portada'],
      companyPhone: json['telefono'],
      businessEmail: json['email'],
      location: json['localidad'],
      images: json['imagenes'] != null
          ? (json['imagenes'] as List).map((e) => Image.fromJson(e)).toList()
          : null,
      bookingUrl: json['urlReserva'],
      webUrl: json['urlWeb'],
      description: json['descripcion'],
      address: json['direccion'],
    );
  }

  factory Accommodation.saved(Map<String, dynamic> json) {
    return Accommodation._(
      id: json['idAlojamiento'],
      name: json['nombre'],
      coverImage: json['portada'],
      accommodationCategory: json['categoriaAlojamiento'],
      location: json['localidad'],
    );
  }
}
