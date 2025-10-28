import 'package:flutter/foundation.dart';

class AppConfig {
  // API Configuration - Use compile-time defines or fallback to dev
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://someurl.com/api/mobile/v1',
  );
  static const String webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'http://someurl.com',
  );

  // Deep Link Configuration
  static const String callbackScheme = 'rule7';
  static const String callbackHost = 'callback';

  // Authorize Endpoint
  static String getAuthorizeUrl(String token, String redirectUri) {
    return '$webBaseUrl/auth/authorize?token=$token&redirect_uri=$redirectUri';
  }

  // Build the full callback URI
  static String buildCallbackUri() {
    if (kIsWeb) {
      // Use the current origin so flutter run -d chrome works on whatever port it picks
      final origin = Uri.base.origin; // e.g. http://localhost:51321
      return '$origin/auth/callback';
    }
    return '$callbackScheme://$callbackHost';
  }

  // Token Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String deviceIdKey = 'device_id';
}
