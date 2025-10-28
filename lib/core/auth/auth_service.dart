import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:rule7_app/config/app_config.dart';
import 'package:rule7_app/core/auth/auth_exception.dart';
import 'package:rule7_app/core/storage/secure_storage.dart';
import 'package:rule7_app/features/auth/models/auth_response.dart';
import 'package:rule7_app/features/auth/models/user.dart';

/// Service for handling authentication operations
class AuthService {
  final Dio _dio;
  final SecureStorage _storage;

  AuthService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          ),
      _storage = SecureStorage();

  /// Exchange auth code for tokens
  Future<AuthResponse> exchangeCode(String code) async {
    try {
      final deviceId = await _storage.read(AppConfig.deviceIdKey);

      final response = await _dio.post(
        '/auth/exchange',
        data: {'code': code},
        options: Options(
          headers: {if (deviceId != null) 'X-Device-Id': deviceId},
        ),
      );

      if (response.statusCode == 200) {
        log('Exchange response data: ${response.data}');
        log('Exchange response data type: ${response.data.runtimeType}');

        final authResponse = AuthResponse.fromJson(response.data);

        // Store tokens
        await _storage.write(
          AppConfig.accessTokenKey,
          authResponse.accessToken,
        );
        await _storage.write(
          AppConfig.refreshTokenKey,
          authResponse.refreshToken,
        );

        return authResponse;
      }

      // Extract meaningful error message
      final msg =
          response.data?['error']?['message'] ??
          response.data?['message'] ??
          'Authorization code exchange failed';
      throw AuthException(msg.toString());
    } catch (e) {
      log('Auth code exchange failed: $e', error: e);

      // Handle DioException with response data
      if (e is DioException) {
        final response = e.response;
        if (response?.data != null) {
          final data = response!.data;
          dynamic message;

          // Try to extract error message from various structures
          if (data is Map) {
            message = data['error'];
            if (message is Map) {
              message = message['message'];
            }
            message ??= data['message'];
          }

          if (message != null && message is String && message.isNotEmpty) {
            throw AuthException(message);
          }
        }

        // Fall back to DioException message
        throw AuthException(e.message ?? 'Authorization code exchange failed');
      }

      rethrow;
    }
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final deviceId = await _storage.read(AppConfig.deviceIdKey);

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {if (deviceId != null) 'X-Device-Id': deviceId},
        ),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);

        // Update stored tokens
        await _storage.write(
          AppConfig.accessTokenKey,
          authResponse.accessToken,
        );
        await _storage.write(
          AppConfig.refreshTokenKey,
          authResponse.refreshToken,
        );

        return authResponse;
      }

      // Extract meaningful error message
      dynamic msg;
      if (response.data is Map) {
        msg = response.data['error'];
        if (msg is Map) {
          msg = msg['message'];
        }
        msg ??= response.data['message'];
      }
      throw AuthException(
        (msg is String && msg.isNotEmpty) ? msg : 'Token refresh failed',
      );
    } catch (e) {
      log('Token refresh failed: $e', error: e);

      // Handle DioException
      if (e is DioException) {
        final response = e.response;
        if (response?.data != null) {
          final data = response!.data;
          dynamic message;

          if (data is Map) {
            message = data['error'];
            if (message is Map) {
              message = message['message'];
            }
            message ??= data['message'];
          }

          if (message != null && message is String && message.isNotEmpty) {
            throw AuthException(message);
          }
        }

        throw AuthException(e.message ?? 'Token refresh failed');
      }

      rethrow;
    }
  }

  /// Logout and revoke tokens
  Future<void> logout() async {
    try {
      final accessToken = await _storage.read(AppConfig.accessTokenKey);
      final refreshToken = await _storage.read(AppConfig.refreshTokenKey);

      if (accessToken != null && refreshToken != null) {
        try {
          await _dio.post(
            '/auth/logout',
            data: {'refresh_token': refreshToken},
            options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
          );
        } catch (e) {
          log('Logout API call failed: $e', error: e);
          // Continue with local cleanup even if API call fails
        }
      }

      // Clear all stored data
      await _storage.deleteAll();
    } catch (e) {
      log('Logout failed: $e', error: e);
      // Clear storage anyway
      await _storage.deleteAll();
    }
  }

  /// Get current user
  Future<User> getCurrentUser() async {
    final accessToken = await _storage.read(AppConfig.accessTokenKey);

    if (accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await _dio.get(
      '/auth/user',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    }

    // Extract meaningful error message
    dynamic msg;
    if (response.data is Map) {
      msg = response.data['error'];
      if (msg is Map) {
        msg = msg['message'];
      }
      msg ??= response.data['message'];
    }
    throw AuthException(
      (msg is String && msg.isNotEmpty) ? msg : 'Failed to get current user',
    );
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await _storage.read(AppConfig.accessTokenKey);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(AppConfig.refreshTokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      log('Checking authentication status...');
      final accessToken = await _storage.read(AppConfig.accessTokenKey);
      log(
        'Access token retrieved: ${accessToken != null && accessToken.isNotEmpty}',
      );
      return accessToken != null && accessToken.isNotEmpty;
    } catch (e) {
      log('Error checking authentication: $e', error: e);
      return false;
    }
  }
}
