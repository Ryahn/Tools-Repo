import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:rule7_app/core/storage/secure_storage.dart';

/// Interceptor for handling authentication and automatic token refresh
class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  bool _isRefreshing = false;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add access token header
    final accessToken = await _storage.read('access_token');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Add device ID header if available
    final deviceId = await _storage.read('device_id');
    if (deviceId != null) {
      options.headers['X-Device-Id'] = deviceId;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 errors for automatic token refresh
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      try {
        _isRefreshing = true;

        // Try to refresh the token
        final success = await _refreshToken();

        if (success) {
          // Retry the original request
          _isRefreshing = false;
          return _retry(err.requestOptions, handler);
        } else {
          // Refresh failed - clear tokens and trigger re-login
          _isRefreshing = false;
          await _handleLogout();
          handler.reject(err);
        }
      } catch (e) {
        _isRefreshing = false;
        log('Token refresh error: $e', error: e);
        await _handleLogout();
        handler.reject(err);
      }
    } else {
      handler.next(err);
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read('refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final dio = Dio();
      dio.options.baseUrl = 'http://rule7.zonies.test/api/mobile/v1';

      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write('access_token', data['access_token']);
        await _storage.write('refresh_token', data['refresh_token']);
        return true;
      }

      return false;
    } catch (e) {
      log('Token refresh failed: $e', error: e);
      return false;
    }
  }

  void _retry(RequestOptions requestOptions, ErrorInterceptorHandler handler) {
    final dio = Dio();
    dio.options.baseUrl = requestOptions.baseUrl;

    dio
        .fetch(requestOptions)
        .then(
          (response) => handler.resolve(response),
          onError: (error) => handler.reject(error as DioException),
        );
  }

  Future<void> _handleLogout() async {
    try {
      await _storage.deleteAll();
      // TODO: Navigate to login screen
    } catch (e) {
      log('Logout error: $e', error: e);
    }
  }
}
