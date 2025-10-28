import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Helper for responsive design and layout decisions
class Responsive {
  final BuildContext context;

  Responsive(this.context);

  /// Get the current MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(context);

  /// Get the current screen width
  double get width => mediaQuery.size.width;

  /// Get the current screen height
  double get height => mediaQuery.size.height;

  /// Determine if the screen is a mobile device (width < 600)
  bool get isMobile => width < 600;

  /// Determine if the screen is a tablet (width >= 600 and < 900)
  bool get isTablet => width >= 600 && width < 900;

  /// Determine if the screen is a desktop (width >= 900)
  bool get isDesktop => width >= 900;

  /// Get the appropriate column count based on screen size
  int getColumnCount({int mobile = 1, int tablet = 2, int desktop = 4}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  /// Get the appropriate padding based on screen size
  EdgeInsets getPadding({
    double mobile = 16,
    double tablet = 24,
    double desktop = 32,
  }) {
    if (isMobile) return EdgeInsets.all(mobile);
    if (isTablet) return EdgeInsets.all(tablet);
    return EdgeInsets.all(desktop);
  }

  /// Check if we're running on web
  bool get isWeb => kIsWeb;

  /// Check if we're running on mobile OS (iOS or Android)
  bool get isMobileOS => Platform.isAndroid || Platform.isIOS;

  /// Check if we're running on desktop OS (macOS, Windows, Linux)
  bool get isDesktopOS =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}
