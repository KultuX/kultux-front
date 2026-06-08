import 'package:kultux/core/models/image.dart';

class Activity {
  final int id;
  final String title;
  final String? activityCategory;
  final String coverImage;
  final String startDate;
  final String? location;
  final String? status;

  String? description;
  String? companyPhone;
  String? businessEmail;
  String? endDate;
  String? endTime;
  String? startTime;
  List<Image>? images;
  String? bookingUrl;
  String? webUrl;
  String? address;
  String? companyName;
  String? companyLogo;
  double? price;
  int? maxCapacity;

  Activity._({
    required this.id,
    required this.title,
    this.activityCategory,
    required this.coverImage,
    required this.startDate,
    this.location,
    this.status,
    this.startTime,
    this.description,
    this.companyPhone,
    this.businessEmail,
    this.endDate,
    this.endTime,
    this.images,
    this.bookingUrl,
    this.webUrl,
    this.address,
    this.companyName,
    this.companyLogo,
    this.price,
    this.maxCapacity
  });

  factory Activity.trending(Map<String, dynamic> json) {
    return Activity._(
      id: json['id'] ?? 0,
      title: json['titulo'] ?? '',
      activityCategory: json['categoriaActividad'] ?? '',
      coverImage:
          json['portada'] ?? '',
        startDate: json['fechaInicio'] ?? '',
      location: json['localidad'] ?? '',
      status: json['estado'],
      endDate: json['fechaFin'] ?? ''
    );
  }

  factory Activity.search(Map<String, dynamic> json) {
    return Activity._(
      id: json['id'] ?? 0,
      title: json['titulo'] ?? '',
      activityCategory: json['categoria'] ?? '',
      coverImage:
          json['portada'] ??
          'https://www.tooltyp.com/wp-content/uploads/2014/10/1900x920-8-beneficios-de-usar-imagenes-en-nuestros-sitios-web.jpg',
      startDate: json['fechaInicio'] ?? '',
      startTime: json['horaInicio'],
      location: json['localidad'] ?? '',
      status: json['estado'],
      endDate: json['fechaFin'] ?? ''
    );
  }

  factory Activity.detail(Map<String, dynamic> json) {
    return Activity._(
      id: json['id'] ?? 0,
      title: json['titulo'] ?? 'No disponible',
      location: json['localidad'] ?? 'No disponible',
      activityCategory: json['categoriaActividad'] ?? 'No disponible',
      coverImage: json['portada'] ?? 'logo_kultux.png',
      startDate: json['fechaInicio'] ?? 'No disponible',
      startTime: json['horaInicio'] ?? 'No disponible',
      description: json['descripcion'] ?? 'No disponible',
      companyPhone: json['telefonoEmpresa'] ?? 'No disponible',
      businessEmail: json['correoEmpresa'] ?? 'No disponible',
      endDate: json['fechaFin'],
      endTime: json['horaFin'],
      images: json['imagenes'] != null
          ? (json['imagenes'] as List).map((e) => Image.fromJson(e)).toList()
          : [],
      status: json['estado'] ,
      bookingUrl: json['urlCompra'],
      webUrl: json['urlWeb'],
      address: json['direccion'],
      companyName: json['nombreEmpresa'],
      companyLogo: json['logotipoUrl'],
      price: json['precio'],
      maxCapacity: json['aforoMaximo']
    );
  }

  factory Activity.saved(Map<String, dynamic> json) {
    return Activity._(
      id: json['idActividad'],
      title: json['titulo'],
      startDate: json['fechaInicio'],
      startTime: json['horaInicio'],
      coverImage: json['portada'],
      activityCategory: json['categoria'],
      location: json['localidad'],
      endDate: json['fechaFin'],
      status: json['estado']
    );
  }
}
