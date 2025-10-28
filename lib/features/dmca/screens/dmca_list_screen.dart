import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rule7_app/features/auth/providers/auth_provider.dart';
import 'package:rule7_app/features/dmca/models/dmca.dart';
import 'package:rule7_app/features/dmca/providers/dmca_provider.dart';
import 'package:rule7_app/features/dmca/screens/dmca_detail_screen.dart';
import 'package:rule7_app/features/dmca/screens/dmca_form_screen.dart';
import 'package:rule7_app/shared/layouts/main_layout.dart';
import 'package:rule7_app/widgets/error_message.dart';
import 'package:rule7_app/widgets/loading_indicator.dart';

/// DMCA List Screen
class DmcaListScreen extends ConsumerStatefulWidget {
  const DmcaListScreen({super.key});

  @override
  ConsumerState<DmcaListScreen> createState() => _DmcaListScreenState();
}

class _DmcaListScreenState extends ConsumerState<DmcaListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSeverity;

  final List<String> _severityOptions = [
    'All',
    '1 Time',
    '2+ Times',
    '3 Times',
    'Unknown',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial data
    ref.read(dmcaListProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(dmcaListProvider.notifier);
      if (notifier.hasMore && !notifier.state.isLoading) {
        notifier.loadMore();
      }
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(dmcaListProvider.notifier).refresh();
  }

  void _onSearchChanged(String value) {
    ref.read(dmcaListProvider.notifier).search(value);
  }

  void _onSeverityChanged(String? value) {
    setState(() {
      _selectedSeverity = value == 'All' ? null : value;
    });
    ref.read(dmcaListProvider.notifier).filterBySeverity(_selectedSeverity);
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case '1 time':
        return Colors.green;
      case '2+ times':
        return Colors.orange;
      case '3 times':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDmcaCard(BuildContext context, Dmca dmca, bool canEdit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ExpansionTile(
        leading: canEdit
            ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => DmcaFormScreen(dmca: dmca),
                        ),
                      )
                      .then((result) {
                        if (result == true) {
                          ref.read(dmcaListProvider.notifier).refresh();
                        }
                      });
                },
              )
            : const SizedBox.shrink(),
        title: Text(
          dmca.gameName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Developer: ${dmca.devName}'),
            const SizedBox(height: 4),
            Chip(
              label: Text(dmca.severity),
              backgroundColor: _getSeverityColor(
                dmca.severity,
              ).withOpacity(0.2),
              labelStyle: TextStyle(
                color: _getSeverityColor(dmca.severity),
                fontWeight: FontWeight.bold,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'URL:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse(dmca.gameUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Text(
                    dmca.gameUrl,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                if (dmca.createdAt != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Created: ${dmca.createdAt!.toLocal()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Details'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DmcaDetailScreen(dmcaId: dmca.id),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dmcasState = ref.watch(dmcaListProvider);
    final authState = ref.watch(authStateProvider);
    final canCreate =
        authState.valueOrNull?.hasPermission('dmca.create') ?? false;
    final canEdit = authState.valueOrNull?.hasPermission('dmca.edit') ?? false;

    return MainLayout(
      title: 'DMCA Entries',
      currentIndex: 2, // DMCA will be the third item in navigation
      actions: canCreate
          ? [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => const DmcaFormScreen(),
                        ),
                      )
                      .then((result) {
                        if (result == true) {
                          ref.read(dmcaListProvider.notifier).refresh();
                        }
                      });
                },
                tooltip: 'Create New DMCA Entry',
              ),
            ]
          : null,
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by game or developer...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSeverity ?? 'All',
                  decoration: const InputDecoration(
                    labelText: 'Filter by Severity',
                    border: OutlineInputBorder(),
                  ),
                  items: _severityOptions.map((severity) {
                    return DropdownMenuItem(
                      value: severity,
                      child: Text(severity),
                    );
                  }).toList(),
                  onChanged: _onSeverityChanged,
                ),
              ],
            ),
          ),

          // DMCA list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: dmcasState.when(
                data: (dmcas) {
                  if (dmcas.isEmpty && !dmcasState.isLoading) {
                    return const Center(child: Text('No DMCA entries found.'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount:
                        dmcas.length +
                        (ref.read(dmcaListProvider.notifier).isLoadingMore
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (index < dmcas.length) {
                        final dmca = dmcas[index];
                        return _buildDmcaCard(context, dmca, canEdit);
                      } else {
                        return const LoadingIndicator();
                      }
                    },
                  );
                },
                loading: () => const LoadingIndicator(),
                error: (error, stack) => ErrorMessage(
                  message: error.toString(),
                  onRetry: _onRefresh,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
