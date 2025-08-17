import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Category> get categories => [..._categories];
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final String _cacheKey = "cached_categories";

  // New, publicly hosted Strapi URL
  final String _baseUrl = "https://kind-bird-79c9416840.strapiapp.com";

  Future<void> fetchCategories({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        try {
          final List data = json.decode(cachedData);
          _categories = data.map((json) => Category.fromJson(json)).toList();
          _isLoading = false;
          notifyListeners();
          return;
        } catch (e) {
          debugPrint("Failed to decode cached data: $e");
        }
      }
    }

    try {
      // The endpoint no longer requires ?populate=*
      final url = Uri.parse("https://kind-bird-79c9416840.strapiapp.com/api/categories");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'];

        _categories = data.map((item) {
          // Direct access to the properties, no nested 'attributes' or 'data'
          return Category(
            id: item['id'].toString(),
            title: item['title'] ?? "No title",
            description: item['description'] ?? "No description",
            imageUrl: item['imageUrl'] ?? "https://placehold.co/400",
          );
        }).toList();

        prefs.setString(
          _cacheKey,
          json.encode(_categories.map((e) => e.toJson()).toList()),
        );
      } else {
        _errorMessage = "Failed to load categories: Server responded with status code ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Network error: Could not connect to the server.";
    }

    _isLoading = false;
    notifyListeners();
  }
}