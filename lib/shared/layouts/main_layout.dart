import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/core/utils/responsive.dart';
import 'package:rule7_app/widgets/app_bar_with_menu.dart';
import 'package:rule7_app/widgets/connectivity_banner.dart';

class MainLayout extends ConsumerWidget {
  final Widget body;
  final String title;
  final int currentIndex;
  final ValueChanged<int>? onNavigationRoute;
  final List<Widget>? actions;

  const MainLayout({
    super.key,
    required this.body,
    required this.title,
    this.currentIndex = 0,
    this.onNavigationRoute,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);

    // For desktop, use a permanent drawer
    if (responsive.isDesktop) {
      return Scaffold(
        appBar: AppBarWithMenu(title: title, actions: actions),
        body: Row(
          children: [
            SizedBox(width: 280, child: _buildDrawer(context, responsive)),
            Expanded(
              child: Column(
                children: [
                  const ConnectivityBanner(),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // For mobile/tablet, use standard drawer
    return Scaffold(
      appBar: AppBarWithMenu(title: title, actions: actions),
      drawer: _buildDrawer(context, responsive),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: responsive.isMobile && _hasMultipleNavItems()
          ? _buildBottomNav()
          : null,
    );
  }

  Widget _buildDrawer(BuildContext context, Responsive responsive) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Rule7 Repo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', 0, () {
            Navigator.pop(context);
            if (onNavigationRoute != null) onNavigationRoute!(0);
          }),
          _buildDrawerItem(Icons.games, 'Games', 1, () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/games');
          }),
          _buildDrawerItem(Icons.copyright, 'DMCA', 2, () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/dmca');
          }),
          _buildDrawerItem(Icons.trending_up, 'Promotions', 3, () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/promotions');
          }),
          _buildDrawerItem(Icons.content_paste, 'Paste', 4, () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/paste/create');
          }),
          // TODO: Add more navigation items as features are implemented
          // _buildDrawerItem(Icons.description, 'Templates', 5, () {}),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'More features coming soon',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    int index,
    VoidCallback onTap,
  ) {
    final isSelected = currentIndex == index;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check) : null,
      selected: isSelected,
      onTap: onTap,
    );
  }

  bool _hasMultipleNavItems() {
    // Count active nav items (uncommented ones)
    // Dashboard and Games are now active (2 items)
    return true;
  }

  Widget? _buildBottomNav() {
    if (!_hasMultipleNavItems()) return null;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onNavigationRoute,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.games), label: 'Games'),
        BottomNavigationBarItem(icon: Icon(Icons.copyright), label: 'DMCA'),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Promotions'),
        BottomNavigationBarItem(icon: Icon(Icons.content_paste), label: 'Paste'),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.report),
        //   label: 'Reports',
        // ),
      ],
    );
  }
}
