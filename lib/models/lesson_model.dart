class Lesson {
  final int id;
  final String title;
  final String slug;
  final String content;
  final String? videoUrl; // can be Media or String
  final List<String> resources; // URLs to PDFs, files
  final int duration; // minutes
  final int order; // sequence in course

  Lesson({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.videoUrl,
    required this.resources,
    required this.duration,
    required this.order,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? json;

    return Lesson(
      id: json['id'] ?? 0,
      title: attributes['title'] ?? '',
      slug: attributes['slug'] ?? '',
      content: attributes['content'] ?? '',
      videoUrl: attributes['videoUrl'] is String
          ? attributes['videoUrl']
          : attributes['videoUrl']?['data']?['attributes']?['url'],
      resources: attributes['resources'] != null
          ? (attributes['resources'] as List)
          .map((r) {
        if (r is Map && r.containsKey('url')) {
          return r['url'] as String;
        } else {
          return r.toString();
        }
      })
          .toList()
          .cast<String>()
          : [],
      duration: attributes['duration'] ?? 0,
      order: attributes['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'videoUrl': videoUrl,
      'resources': resources,
      'duration': duration,
      'order': order,
    };
  }
}
