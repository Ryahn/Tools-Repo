import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/core/auth/auth_service.dart';
import 'package:rule7_app/features/auth/models/user.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = FutureProvider<User?>((ref) async {
  try {
    print('AuthStateProvider: Starting check...');
    final authService = ref.watch(authServiceProvider);

    // Check if user is authenticated
    final isAuth = await authService.isAuthenticated();
    print('AuthStateProvider: isAuthenticated = $isAuth');

    if (!isAuth) {
      print('AuthStateProvider: Not authenticated, returning null');
      return null;
    }

    try {
      print('AuthStateProvider: Getting current user...');
      final user = await authService.getCurrentUser();
      print('AuthStateProvider: User retrieved: ${user.name}');
      return user;
    } catch (e) {
      print('AuthStateProvider: Error getting user: $e');
      return null;
    }
  } catch (e) {
    print('AuthStateProvider: Error in provider: $e');
    return null;
  }
});

// Helper functions for auth actions
// These are deprecated - use authService directly instead
