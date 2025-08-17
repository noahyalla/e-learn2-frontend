// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  String? _jwtToken;
  Map<String, dynamic>? _userData;

  String? get jwtToken => _jwtToken;
  Map<String, dynamic>? get userData => _userData;

  bool get isAuthenticated => _jwtToken != null;

  UserProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final userJson = prefs.getString('user_data');

    if (token != null && userJson != null) {
      _jwtToken = token;
      _userData = json.decode(userJson);
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    // This is a placeholder. Replace with your actual Strapi API endpoint.
    const url = 'https://kind-bird-79c9416840.strapiapp.com/api/auth/local';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'identifier': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      _jwtToken = responseData['jwt'];
      _userData = responseData['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', _jwtToken!);
      await prefs.setString('user_data', json.encode(_userData));

      notifyListeners();
    } else {
      // Handle login error
      throw Exception('Failed to log in: ${response.body}');
    }
  }

  Future<void> logout() async {
    _jwtToken = null;
    _userData = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
    notifyListeners();
  }
}