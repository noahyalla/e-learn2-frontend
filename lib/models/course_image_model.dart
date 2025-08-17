class CourseImage {
  final int id;
  final String documentId;
  final String name;
  final String url;

  CourseImage({
    required this.id,
    required this.documentId,
    required this.name,
    required this.url,
  });

  factory CourseImage.fromJson(Map<String, dynamic> json) {
    return CourseImage(
      id: json['id'],
      documentId: json['documentId'],
      name: json['name'],
      url: json['url'],
    );
  }
}
