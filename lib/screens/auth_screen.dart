import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'reset_password_screen.dart';
import '../utilities/deep_link_handler.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DeepLinkHandler _deepLinkHandler;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerUsernameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _forgotEmailController = TextEditingController();

  final String strapiUrl = "https://kind-bird-79c9416840.strapiapp.com"; // update to backend IP

  bool _isLoggedIn = false;
  String? _username;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkLoginStatus();

    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: 2, vsync: this);
      _checkLoginStatus();

      _deepLinkHandler = DeepLinkHandler(context);
      _deepLinkHandler.init();
    }

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
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$strapiUrl/api/auth/local"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": _loginEmailController.text,
          "password": _loginPasswordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveSession(data["jwt"], data["user"]["username"]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome ${data['user']['username']}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"]["message"] ?? "Login failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> register() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$strapiUrl/api/auth/local/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _registerUsernameController.text,
          "email": _registerEmailController.text,
          "password": _registerPasswordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveSession(data["jwt"], data["user"]["username"]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered & logged in successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"]["message"] ?? "Registration failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> forgotPassword() async {
    if (_forgotEmailController.text.isEmpty ||
        !_forgotEmailController.text.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid email")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$strapiUrl/api/auth/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": _forgotEmailController.text}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Password reset email sent! Click the link in your email to reset."),
          ),
        );
        Navigator.pop(context); // Close dialog after confirmation
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  errorData["error"]["message"] ?? "Error sending reset email")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void _navigateToResetPassword(String code) {
    // Close the forgot password dialog if open
    if (Navigator.canPop(context)) Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(code: code),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Forgot Password"),
        content: TextField(
          controller: _forgotEmailController,
          decoration: const InputDecoration(
            hintText: "Enter your email",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => _handleForgotPassword(),
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleForgotPassword() async {
    final email = _forgotEmailController.text.trim();

    if (email.isEmpty || !email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid email")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$strapiUrl/api/auth/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        // Notify user to check email
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Password reset email sent! Click the link in your email to reset."),
            duration: Duration(seconds: 4),
          ),
        );

        // Close dialog automatically after confirmation
        Navigator.pop(context);
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorData["error"]["message"] ?? "Error sending reset email",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      // ✅ Dashboard after login
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

    // ✅ Auth screen
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Sign In Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _loginFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _loginEmailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (value) => value != null &&
                        value.contains("@")
                        ? null
                        : "Enter a valid email",
                  ),
                  TextFormField(
                    controller: _loginPasswordController,
                    decoration:
                    const InputDecoration(labelText: "Password"),
                    obscureText: true,
                    validator: (value) =>
                    value != null && value.length >= 6
                        ? null
                        : "Password must be at least 6 chars",
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
          ),

          // Register Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _registerFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _registerUsernameController,
                    decoration:
                    const InputDecoration(labelText: "Username"),
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "Username required",
                  ),
                  TextFormField(
                    controller: _registerEmailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (value) => value != null &&
                        value.contains("@")
                        ? null
                        : "Enter a valid email",
                  ),
                  TextFormField(
                    controller: _registerPasswordController,
                    decoration:
                    const InputDecoration(labelText: "Password"),
                    obscureText: true,
                    validator: (value) =>
                    value != null && value.length >= 6
                        ? null
                        : "Password must be at least 6 chars",
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: register,
                    child: const Text("Register"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

