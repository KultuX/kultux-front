class Image {
  final int idImagen;
  final int idAsociado;
  final bool esPortada;
  final String url;

  Image({
    required this.idImagen,
    required this.idAsociado,
    required this.esPortada,
    required this.url,
  });
  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      idImagen:
          json['idImagenActividad'] ??
          json['idImagenAlojamiento'] ??
          json['idImagenRestaurante'],
      idAsociado:
          json['idActividad'] ?? json['idAlojamiento'] ?? json['idRestaurante'],
      url: json['urlImagen'],
      esPortada: json['esPortada'],
    );
  }
}
