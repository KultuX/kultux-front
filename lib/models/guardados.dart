class Guardado {
  final bool guardado;
  final bool yaExistia;

  Guardado({required this.guardado, required this.yaExistia});

  factory Guardado.fromJson(Map<String, dynamic> json) {
    return Guardado(
      guardado: json['guardado'] as bool,
      yaExistia: json['yaExistia'] as bool,
    );
  }
}