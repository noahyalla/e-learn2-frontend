import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String code;

  const ResetPasswordScreen({super.key, required this.code});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final String strapiUrl = "https://kind-bird-79c9416840.strapiapp.com";

  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resetPasswordAndLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Reset password via Strapi
      final resetResponse = await http.post(
        Uri.parse("$strapiUrl/api/auth/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "code": widget.code,
          "password": _passwordController.text,
          "passwordConfirmation": _passwordController.text,
        }),
      );

      final resetData = jsonDecode(resetResponse.body);

      if (resetResponse.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resetData["error"]["message"] ?? "Reset failed")),
        );
        return;
      }

      final email = resetData["user"]["email"];
      final password = _passwordController.text;

      // 2️⃣ Auto-login
      final loginResponse = await http.post(
        Uri.parse("$strapiUrl/api/auth/local"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"identifier": email, "password": password}),
      );

      final loginData = jsonDecode(loginResponse.body);

      if (loginResponse.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwt", loginData["jwt"]);
        await prefs.setString("username", loginData["user"]["username"]);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset & logged in!")),
        );

        // Navigate to dashboard (pop all previous routes)
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loginData["error"]["message"] ?? "Login failed")),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "New Password"),
                obscureText: true,
                validator: (value) =>
                value != null && value.length >= 6
                    ? null
                    : "Password must be at least 6 chars",
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _resetPasswordAndLogin,
                child: const Text("Reset Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
