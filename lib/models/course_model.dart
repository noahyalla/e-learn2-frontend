import 'lesson_model.dart';
import 'category_model.dart';
import 'instructor_model.dart';
import 'course_image_model.dart';

class Course {
  final int id;
  final String documentId;
  final String title;
  final String description;
  final String slug;
  final String level;
  final int duration;
  final String language;
  final double? price;
  final CourseImage? courseImage;
  final List<Lesson> lessons;
  final Category category;
  final List<Instructor> instructors;

  Course({
    required this.id,
    required this.documentId,
    required this.title,
    required this.description,
    required this.slug,
    required this.level,
    required this.duration,
    required this.language,
    required this.price,
    required this.courseImage,
    required this.lessons,
    required this.category,
    required this.instructors,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      documentId: json['documentId'],
      title: json['title'],
      description: json['description'],
      slug: json['slug'],
      level: json['level'] ?? "Unknown",
      duration: json['duration'] ?? 0,
      language: json['language'] ?? "English",
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      courseImage: json['courseImage'] != null
          ? CourseImage.fromJson(json['courseImage'])
          : null,
      lessons: (json['lessons'] as List<dynamic>?)
          ?.map((l) => Lesson.fromJson(l))
          .toList() ??
          [],
      category: Category.fromJson(json['category']),
      instructors: (json['instructors'] as List<dynamic>?)
          ?.map((i) => Instructor.fromJson(i))
          .toList() ??
          [],
    );
  }
}
