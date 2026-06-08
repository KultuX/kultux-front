class Saved {
  final bool saved;
  final bool exists;

  Saved({required this.saved, required this.exists});

  factory Saved.fromJson(Map<String, dynamic> json) {
    return Saved(
      saved: json['guardado'] as bool,
      exists: json['yaExistia'] as bool,
    );
  }
}
