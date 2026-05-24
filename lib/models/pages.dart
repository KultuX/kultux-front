class Pages<T> {
  final List<T> contenido;
  final int numero;
  final int totalPaginas;
  final int totalElementos;

  Pages._({
    required this.contenido,
    required this.numero,
    required this.totalPaginas,
    required this.totalElementos,
  });

  factory Pages.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final List contentRaw = json['content'] ?? [];

    return Pages._(
      contenido: contentRaw.map((e) => fromJsonT(e)).toList(),
      numero: json['number'],
      totalPaginas: json['totalPages'],
      totalElementos: json['totalElements'] ?? 0
    );
  }
}
