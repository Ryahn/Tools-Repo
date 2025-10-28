import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/core/auth/auth_service.dart';
import 'package:rule7_app/features/auth/providers/auth_provider.dart';
import 'package:rule7_app/features/auth/screens/login_screen.dart';

class AppBarWithMenu extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final List<Widget> customActions;

  const AppBarWithMenu({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.customActions = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        // Custom actions
        ...customActions,
        ...?actions,
        // User menu
        authState.when(
          data: (user) => user != null
              ? _buildUserMenu(context, ref, user)
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context, WidgetRef ref, user) {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(user.name.substring(0, 1).toUpperCase()),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person),
              const SizedBox(width: 8),
              Text(user.name),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'email',
          enabled: false,
          child: Text(
            user.email,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [Icon(Icons.logout), SizedBox(width: 8), Text('Logout')],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          _handleLogout(context, ref);
        }
        // Add other menu actions here
      },
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Logout via AuthService provider
      final authService = AuthService();
      await authService.logout();
      ref.invalidate(authStateProvider);

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
