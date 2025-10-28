import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/features/auth/models/user.dart';
import 'package:rule7_app/features/auth/providers/auth_provider.dart';
import 'package:rule7_app/features/dashboard/models/dashboard_stats.dart';
import 'package:rule7_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:rule7_app/shared/layouts/main_layout.dart';
import 'package:rule7_app/widgets/error_banner.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MainLayout(
      title: 'Dashboard',
      currentIndex: 0,
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user data'));
          }

          final statsState = ref.watch(dashboardStatsProvider);

          return statsState.when(
            data: (stats) => _buildStatsContent(context, user, stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ErrorBanner(
                  message: 'Failed to load statistics: $error',
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ErrorBanner(message: 'Error: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent(
    BuildContext context,
    User user,
    DashboardStats stats,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // Future: implement refresh
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user.name}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats cards
            Text('Statistics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // Games stats
            _buildStatsCard(
              context,
              title: 'Games',
              icon: Icons.games,
              color: Colors.blue,
              children: [
                _buildStatRow('Total', stats.games.total.toString()),
                _buildStatRow(
                  'Approved',
                  stats.games.approved.toString(),
                  success: true,
                ),
                _buildStatRow('Pending', stats.games.pending.toString()),
                _buildStatRow(
                  'Banned',
                  stats.games.banned.toString(),
                  danger: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Reports stats
            _buildStatsCard(
              context,
              title: 'Reports',
              icon: Icons.report,
              color: Colors.orange,
              children: [
                _buildStatRow('Total', stats.reports.total.toString()),
              ],
            ),

            const SizedBox(height: 16),

            // Uploaders stats
            _buildStatsCard(
              context,
              title: 'Uploaders',
              icon: Icons.upload,
              color: Colors.green,
              children: [
                _buildStatRow('Total', stats.uploaders.total.toString()),
                _buildStatRow(
                  'Full Uploaders',
                  stats.uploaders.full.toString(),
                ),
                _buildStatRow(
                  'Junior Uploaders',
                  stats.uploaders.junior.toString(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // DMCA stats
            _buildStatsCard(
              context,
              title: 'DMCA',
              icon: Icons.copyright,
              color: Colors.red,
              children: [_buildStatRow('Total', stats.dmca.total.toString())],
            ),

            const SizedBox(height: 16),

            // Promotions stats
            _buildStatsCard(
              context,
              title: 'Promotions',
              icon: Icons.local_offer,
              color: Colors.purple,
              children: [
                _buildStatRow('Total', stats.promotions.total.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value, {
    bool success = false,
    bool danger = false,
  }) {
    Color valueColor = Colors.white;
    if (success) valueColor = Colors.greenAccent;
    if (danger) valueColor = Colors.redAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }
}
