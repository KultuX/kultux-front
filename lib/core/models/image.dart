class Image {
  final int imageId;
  final int modelId;
  final bool isCover;
  final String url;

  Image({
    required this.imageId,
    required this.modelId,
    required this.isCover,
    required this.url,
  });
  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      imageId:
          json['idImagenActividad'] ??
          json['idImagenAlojamiento'] ??
          json['idImagenRestaurante'],
      modelId:
          json['idActividad'] ?? json['idAlojamiento'] ?? json['idRestaurante'],
      url: json['urlImagen'],
      isCover: json['esPortada'],
    );
  }
}
