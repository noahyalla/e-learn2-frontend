import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/lesson_model.dart';

class LessonProvider with ChangeNotifier {
  List<Lesson> _lessons = [];
  List<Lesson> get lessons => [..._lessons];

  final String baseUrl = "https://kind-bird-79c9416840.strapiapp.com/api/lessons";

  Future<void> fetchLessons() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl?populate=*"));
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        final data = extractedData['data'] as List;
        _lessons = data.map((l) => Lesson.fromJson(l)).toList();
        notifyListeners();
      } else {
        throw Exception("Failed to load lessons");
      }
    } catch (error) {
      rethrow;
    }
  }

  Lesson? findById(int id) {
    return _lessons.firstWhere((l) => l.id == id, orElse: () => null as Lesson);
  }

  List<Lesson> getLessonsByCourse(int courseId) {
    return _lessons.where((l) => l.id == courseId).toList();
  }
}
