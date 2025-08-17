import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/instructor_model.dart';

class InstructorProvider with ChangeNotifier {
  List<Instructor> _instructors = [];
  List<Instructor> get instructors => [..._instructors];

  final String baseUrl = "https://kind-bird-79c9416840.strapiapp.com/api/instructors"; // replace with your IP if testing on device

  Future<void> fetchInstructors() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl?populate=*"));
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        final data = extractedData['data'] as List;
        _instructors = data.map((i) => Instructor.fromJson(i)).toList();
        notifyListeners();
      } else {
        throw Exception("Failed to load instructors");
      }
    } catch (error) {
      rethrow;
    }
  }

  Instructor? findById(int id) {
    return _instructors.firstWhere((i) => i.id == id, orElse: () => null as Instructor);
  }
}
