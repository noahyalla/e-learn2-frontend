import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerUsernameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _forgotEmailController = TextEditingController();

  final String strapiUrl = "http://10.0.2.2:1337"; // Change to your backend IP
  bool _isLoggedIn = false;
  String? _username;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _checkLoginStatus();
    super.initState();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt");
    final username = prefs.getString("username");

    if (token != null && username != null) {
      setState(() {
        _isLoggedIn = true;
        _username = username;
      });
    }
  }

  Future<void> _saveSession(String token, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("jwt", token);
    await prefs.setString("username", username);

    setState(() {
      _isLoggedIn = true;
      _username = username;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      _isLoggedIn = false;
      _username = null;
    });
  }

  Future<void> login() async {
    final response = await http.post(
      Uri.parse("$strapiUrl/api/auth/local"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "identifier": _loginEmailController.text,
        "password": _loginPasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveSession(data["jwt"], data["user"]["username"]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome ${data['user']['username']}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    }
  }

  Future<void> register() async {
    final response = await http.post(
      Uri.parse("$strapiUrl/api/auth/local/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": _registerUsernameController.text,
        "email": _registerEmailController.text,
        "password": _registerPasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveSession(data["jwt"], data["user"]["username"]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registered & logged in successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration failed")),
      );
    }
  }

  Future<void> forgotPassword() async {
    final response = await http.post(
      Uri.parse("$strapiUrl/api/auth/forgot-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": _forgotEmailController.text}),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending reset email")),
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Forgot Password"),
        content: TextField(
          controller: _forgotEmailController,
          decoration: const InputDecoration(hintText: "Enter your email"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: forgotPassword,
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      // ✅ Show logged-in screen
      return Scaffold(
        appBar: AppBar(title: const Text("Dashboard")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Hello, $_username 👋",
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Show Auth screen
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auth"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Sign In"),
            Tab(text: "Register"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Sign In Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _loginEmailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: _loginPasswordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: login,
                  child: const Text("Sign In"),
                ),
                TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: const Text("Forgot Password?"),
                ),
              ],
            ),
          ),

          // Register Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _registerUsernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                ),
                TextField(
                  controller: _registerEmailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: _registerPasswordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: register,
                  child: const Text("Register"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
