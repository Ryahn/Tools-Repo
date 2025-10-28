import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/config/app_config.dart';
import 'package:rule7_app/features/auth/providers/auth_provider.dart';
import 'package:rule7_app/widgets/error_banner.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Generate a unique session token for this login request
      // This is just an identifier, not validated
      final token = DateTime.now().millisecondsSinceEpoch.toString();

      // Build the authorize URL - this will open Rule7 website
      // If not logged in, user will see F95Zone login
      // If already logged in, user will see consent screen
      final redirectUri = AppConfig.buildCallbackUri();
      final authorizeUrl = AppConfig.getAuthorizeUrl(token, redirectUri);

      print('Opening browser to: $authorizeUrl');

      // Open browser with authorize URL
      final uri = Uri.parse(authorizeUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch browser');
      }

      // Reset loading state - user is now in browser
      setState(() {
        _isLoading = false;
      });

      // Note: Deep link handler will be set up in main.dart
      // It will call authStateProvider.notifier.login(code) when callback is received
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Login failed: ${e.toString()}';
      });
    }
  }

  Future<void> _testWithMockCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch a fresh test auth code from the backend
      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.webBaseUrl,
          headers: {'Accept': 'application/json'},
        ),
      );

      final response = await dio.get('/api/mobile/v1/auth/test-code');
      final mockCode = response.data['code'] as String;

      print('Fetched test code: $mockCode');

      // Exchange code for tokens
      final authService = ref.read(authServiceProvider);
      await authService.exchangeCode(mockCode);

      // Invalidate auth state to trigger refresh
      ref.invalidate(authStateProvider);

      // Force navigation to dashboard after successful login
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      print('Error in test login: $e');
      final errorMsg = e.toString().trim();
      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg.isEmpty
            ? 'An unknown error occurred'
            : errorMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.games_outlined,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // App Name
                Text(
                  'Rule7',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Game Database & Templates',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 48),

                // Error Message
                if (_errorMessage != null) ...[
                  ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 24),
                ],

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login),
                            SizedBox(width: 8),
                            Text('Login'),
                          ],
                        ),
                ),
                const SizedBox(height: 16),

                // Test Login Button (for development)
                OutlinedButton(
                  onPressed: _isLoading ? null : _testWithMockCode,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Test Login (Mock)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
