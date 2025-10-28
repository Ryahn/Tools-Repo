import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/features/auth/providers/auth_provider.dart';

class WebAuthCallbackScreen extends ConsumerStatefulWidget {
  const WebAuthCallbackScreen({super.key});

  @override
  ConsumerState<WebAuthCallbackScreen> createState() =>
      _WebAuthCallbackScreenState();
}

class _WebAuthCallbackScreenState extends ConsumerState<WebAuthCallbackScreen> {
  bool _handled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _finishAuthIfNeeded();
  }

  Future<void> _finishAuthIfNeeded() async {
    if (_handled) return;
    _handled = true;

    final uri = Uri.base; // current browser URL
    print('WebAuthCallback: Current URI = $uri');
    final code = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];
    final errorDesc = uri.queryParameters['error_description'];

    print('WebAuthCallback: code = $code, error = $error');

    if (error != null) {
      // Show a minimal error, then return to splash/login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorDesc ?? 'Authorization failed: $error')),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.of(context).pushReplacementNamed('/');
      return;
    }

    if (code == null || code.isEmpty) {
      // Nothing useful here; go home
      if (mounted) Navigator.of(context).pushReplacementNamed('/');
      return;
    }

    try {
      print('WebAuthCallback: Exchanging code...');
      final authService = ref.read(authServiceProvider);
      await authService.exchangeCode(code);
      ref.invalidate(authStateProvider);
      print('WebAuthCallback: Code exchanged successfully');
      if (mounted) {
        print('WebAuthCallback: Navigating to dashboard');
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      print('WebAuthCallback: Exchange failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login exchange failed: $e')));
      if (mounted) Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
