class Imagen{
  final int idImagen;
  final int idAsociado;
  final bool esPortada;
  final String url;

  Imagen({
    required this.idImagen,
    required this.idAsociado,
    required this.esPortada,
    required this.url
  });
  factory Imagen.fromJson(Map<String, dynamic> json) {
    return Imagen(
      idImagen: json['idImagenActividad'] ?? json['idImagenAlojamiento'] ?? json['idImagenRestaurante'],
      idAsociado: json['idActividad'] ?? json['idAlojamiento'] ?? json['idRestaurante'],
      url: json['urlImagen'],
      esPortada: json['esPortada'],
    );
  }
}