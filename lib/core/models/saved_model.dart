class Saved {
  final bool guardado;
  final bool yaExistia;

  Saved({required this.guardado, required this.yaExistia});

  factory Saved.fromJson(Map<String, dynamic> json) {
    return Saved(
      guardado: json['guardado'] as bool,
      yaExistia: json['yaExistia'] as bool,
    );
  }
}
