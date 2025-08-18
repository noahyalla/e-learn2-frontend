import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/user_dashboard_screen.dart';
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

  final String strapiUrl = "https://kind-bird-79c9416840.strapiapp.com";

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _deepLinkHandler = DeepLinkHandler(context);
    _deepLinkHandler.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.login(
        _loginEmailController.text.trim(),
        _loginPasswordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome ${userProvider.userData?['username']}")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            username: userProvider.userData?['username'] ?? 'User',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> register() async {
    if (!_registerFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final response = await http.post(
        Uri.parse("$strapiUrl/api/auth/local/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _registerUsernameController.text.trim(),
          "email": _registerEmailController.text.trim(),
          "password": _registerPasswordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await userProvider.login(
          _registerEmailController.text.trim(),
          _registerPasswordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome ${data['user']['username']}")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              username: data["user"]["username"],
            ),
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData["error"]["message"] ?? "Registration failed"),
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

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Forgot Password"),
        content: TextField(
          controller: _forgotEmailController,
          decoration: InputDecoration(
            hintText: "Enter your email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _handleForgotPassword,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent!")),
        );
        Navigator.pop(context);
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData["error"]["message"] ?? "Error sending reset email"),
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
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 40),
              // Hero Section
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in or register to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Tab Selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  tabs: const [
                    Tab(text: "Sign In"),
                    Tab(text: "Register"),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Forms
              SizedBox(
                height: 450, // Fixed height to prevent overflow
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Sign In Tab
                    _buildLoginForm(),
                    // Register Tab
                    _buildRegisterForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Inside _buildLoginForm()
  Widget _buildLoginForm() {
    return Card(
      // ...
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _loginFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _loginEmailController,
                decoration: _buildInputDecoration('Email', Icons.email),
                style: const TextStyle(color: Colors.black87), // Added style
                validator: (value) => value != null && value.contains("@")
                    ? null
                    : "Enter a valid email",
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _loginPasswordController,
                decoration: _buildInputDecoration('Password', Icons.lock),
                style: const TextStyle(color: Colors.black87), // Added style
                obscureText: true,
                validator: (value) => value != null && value.length >= 6
                    ? null
                    : "Password must be at least 6 chars",
              ),
              const SizedBox(height: 24),
              _buildGradientButton(
                onPressed: login,
                label: "Sign In",
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _showForgotPasswordDialog,
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Inside _buildRegisterForm()
  Widget _buildRegisterForm() {
    return Card(
      // ...
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _registerFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _registerUsernameController,
                decoration: _buildInputDecoration('Username', Icons.person),
                style: const TextStyle(color: Colors.black87), // Added style
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : "Username required",
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _registerEmailController,
                decoration: _buildInputDecoration('Email', Icons.email),
                style: const TextStyle(color: Colors.black87), // Added style
                validator: (value) => value != null && value.contains("@")
                    ? null
                    : "Enter a valid email",
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _registerPasswordController,
                decoration: _buildInputDecoration('Password', Icons.lock),
                style: const TextStyle(color: Colors.black87), // Added style
                obscureText: true,
                validator: (value) => value != null && value.length >= 6
                    ? null
                    : "Password must be at least 6 chars",
              ),
              const SizedBox(height: 24),
              _buildGradientButton(
                onPressed: register,
                label: "Register",
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  Widget _buildGradientButton({required VoidCallback onPressed, required String label}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF50BFE6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}