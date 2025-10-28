import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:rule7_app/config/theme.dart';
import 'package:rule7_app/features/auth/providers/auth_provider.dart';
import 'package:rule7_app/features/auth/screens/splash_screen.dart';
import 'package:rule7_app/features/auth/screens/web_auth_callback_screen.dart';
import 'package:rule7_app/features/dashboard/dashboard_screen.dart';
import 'package:rule7_app/features/dmca/screens/dmca_list_screen.dart';
import 'package:rule7_app/features/games/screens/games_list_screen.dart';
import 'package:rule7_app/features/paste/screens/paste_create_screen.dart';
import 'package:rule7_app/features/promotions/screens/promotions_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late AppLinks _appLinks;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinkHandler();
  }

  Future<void> _initDeepLinkHandler() async {
    _appLinks = AppLinks();

    // Handle deep links when app is already open
    _appLinks.uriLinkStream.listen((uri) {
      print('Received deep link: $uri');
      _handleDeepLink(uri);
    });

    // Handle deep links when app is opened from a link
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      print('Initial deep link: $initialLink');

      // If it's an HTTP callback URL, let the route system handle it
      // instead of the deep link handler
      if (initialLink.scheme == 'http' || initialLink.scheme == 'https') {
        print('Initial link is HTTP, skipping deep link handler');
        // The route will be handled by onGenerateRoute based on the current URL
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeepLink(initialLink);
      });
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    print('Handling deep link: $uri');

    // Only handle rule7:// deep links, not HTTP URLs
    if (uri.scheme != 'rule7') {
      print('Ignoring non-rule7 deep link: ${uri.scheme}');
      return;
    }

    if (uri.scheme == 'rule7' && uri.host == 'callback') {
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        print('Deep link error: $error');
        // Show error to user
        return;
      }

      if (code != null) {
        print('Exchanging code for tokens: $code');
        try {
          // Exchange code for tokens directly
          final authService = ref.read(authServiceProvider);
          await authService.exchangeCode(code);
          ref.invalidate(authStateProvider);

          // Navigate to dashboard using navigator key
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/dashboard',
            (route) => false,
          );
        } catch (e) {
          print('Error exchanging code: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Rule7',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      // Use onGenerateRoute to handle current URL on web
      onGenerateRoute: (settings) {
        print('Generating route for: ${settings.name}');

        // Check the actual browser URL path
        final currentPath = Uri.base.path;
        print('Current browser path: $currentPath');

        // Use the browser path if settings.name is just '/'
        final routeName = (settings.name == '/' && currentPath != '/')
            ? currentPath
            : settings.name;
        print('Using route: $routeName');

        switch (routeName) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case '/games':
            return MaterialPageRoute(builder: (_) => const GamesListScreen());
          case '/dmca':
            return MaterialPageRoute(builder: (_) => const DmcaListScreen());
          case '/promotions':
            return MaterialPageRoute(builder: (_) => const PromotionsListScreen());
          case '/paste/create':
            return MaterialPageRoute(builder: (_) => const PasteCreateScreen());
          case '/auth/callback':
            print('Routing to WebAuthCallbackScreen');
            return MaterialPageRoute(
              builder: (_) => const WebAuthCallbackScreen(),
            );
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
