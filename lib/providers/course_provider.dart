import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

class CourseProvider with ChangeNotifier {
  List<Course> _courses = [];
  bool isLoading = false;
  String errorMessage = "";

  List<Course> get courses => [..._courses];

  Future<void> fetchCourses() async {
    isLoading = true;
    errorMessage = "";
    notifyListeners();

    final url = Uri.parse("https://kind-bird-79c9416840.strapiapp.com/api/courses?populate=*");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final extracted = json.decode(response.body);

        if (extracted["data"] == null) {
          errorMessage = "No courses found.";
          _courses = [];
        } else {
          _courses = (extracted["data"] as List)
              .map((courseJson) => Course.fromJson(courseJson))
              .toList();
        }
      } else {
        errorMessage =
        "Failed to load courses (status ${response.statusCode})";
      }
    } catch (e) {
      errorMessage = "Error fetching courses: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}
