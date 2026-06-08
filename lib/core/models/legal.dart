class Legal{
  final String title;
  final String text;
  final bool isFooter;

  Legal._({required this.title, required this.text, this.isFooter = false});

  factory Legal.fromJson(Map<String, dynamic> json){
    return Legal._(
      title: json['title'],
      text: json['text'],
      isFooter: json['isFooter'] ?? false
    );
  }
}