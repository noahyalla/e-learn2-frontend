import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../screens/reset_password_screen.dart';

class DeepLinkHandler {
  final BuildContext context;
  final AppLinks _appLinks = AppLinks(); // Create AppLinks instance
  StreamSubscription<Uri?>? _sub;

  DeepLinkHandler(this.context);

  void init() async {
    // Handle cold start
    try {
      final initialUri = await _appLinks.getInitialLink();
      _handleUri(initialUri);
    } catch (err) {
      print("Failed to get initial app link: $err");
    }

    // Listen for incoming deep links while app is running
    _sub = _appLinks.uriLinkStream.listen(_handleUri, onError: (err) {
      print("Deep link error: $err");
    });
  }

  void _handleUri(Uri? uri) {
    if (uri == null) return;

    print("Received deep link: $uri");

    switch (uri.path) {
      case "/reset-password":
        final code = uri.queryParameters["code"];
        if (code != null) _navigateToResetPassword(code);
        break;
    // Add more deep link paths here if needed
    }
  }

  void _navigateToResetPassword(String code) {
    if (Navigator.canPop(context)) Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(code: code),
      ),
    );
  }

  void dispose() => _sub?.cancel();
}
