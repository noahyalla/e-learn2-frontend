
class Instructor {
  final int id;
  final String name;
  final String bio;
  final String? profilePicture; // URL
  final Map<String, dynamic>? socialLinks; // JSON object from Strapi

  Instructor({
    required this.id,
    required this.name,
    required this.bio,
    this.profilePicture,
    this.socialLinks,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? json;

    return Instructor(
      id: json['id'] ?? 0,
      name: attributes['name'] ?? '',
      bio: attributes['bio'] ?? '',
      profilePicture: attributes['profilePicture']?['data']?['attributes']?['url'],
      socialLinks: attributes['socialLinks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'profilePicture': profilePicture,
      'socialLinks': socialLinks,
    };
  }
}
