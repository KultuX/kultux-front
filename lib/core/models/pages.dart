class Pages<T> {
  final List<T> content;
  final int number;
  final int totalPages;
  final int totalElements;

  Pages._({
    required this.content,
    required this.number,
    required this.totalPages,
    required this.totalElements,
  });

  factory Pages.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final List contentRaw = json['content'] ?? [];

    return Pages._(
      content: contentRaw.map((e) => fromJsonT(e)).toList(),
      number: json['number'],
      totalPages: json['totalPages'],
      totalElements: json['totalElements'] ?? 0
    );
  }
}
