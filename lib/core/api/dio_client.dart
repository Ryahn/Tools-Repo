import 'package:dio/dio.dart';
import 'package:rule7_app/config/app_config.dart';
import 'package:rule7_app/core/api/auth_interceptor.dart';
import 'package:rule7_app/core/storage/secure_storage.dart';

class DioClient {
  static DioClient? _instance;
  static DioClient get instance => _instance ??= DioClient._internal();

  final Dio _dio;

  DioClient._internal() : _dio = Dio() {
    _setupDio();
    // Add auth interceptor by default
    final authInterceptor = AuthInterceptor(SecureStorage());
    _dio.interceptors.add(authInterceptor);
  }

  void _setupDio() {
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Initialize with auth interceptor
  void initializeWithAuth(AuthInterceptor authInterceptor) {
    _dio.interceptors.clear();
    _dio.interceptors.add(authInterceptor);
  }

  /// Set access token header
  void setAccessToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  /// Set device ID header
  void setDeviceId(String? deviceId) {
    if (deviceId != null) {
      _dio.options.headers['X-Device-Id'] = deviceId;
    } else {
      _dio.options.headers.remove('X-Device-Id');
    }
  }

  /// Clear all headers
  void clearHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
