import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rule7_app/features/promotions/models/promotion.dart';
import 'package:rule7_app/features/auth/providers/auth_provider.dart';
import 'package:rule7_app/features/promotions/providers/promotion_provider.dart';
import 'package:rule7_app/features/promotions/screens/promotion_detail_screen.dart';
import 'package:rule7_app/features/promotions/screens/promotion_form_screen.dart';
import 'package:rule7_app/shared/layouts/main_layout.dart';
import 'package:rule7_app/widgets/confirmation_dialog.dart';
import 'package:rule7_app/widgets/error_message.dart';
import 'package:rule7_app/widgets/loading_indicator.dart';

/// Promotions List Screen (read-only)
class PromotionsListScreen extends ConsumerStatefulWidget {
  const PromotionsListScreen({super.key});

  @override
  ConsumerState<PromotionsListScreen> createState() =>
      _PromotionsListScreenState();
}

class _PromotionsListScreenState extends ConsumerState<PromotionsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _threadIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial data
    ref.read(promotionListProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _threadIdController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(promotionListProvider.notifier);
      final state = ref.read(promotionListProvider);
      if (notifier.hasMore && !state.isLoading) {
        notifier.loadMore();
      }
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(promotionListProvider.notifier).refresh();
  }

  void _onSearchChanged(String value) {
    ref.read(promotionListProvider.notifier).search(value);
  }

  void _onThreadIdChanged(String value) {
    final threadId = int.tryParse(value);
    ref.read(promotionListProvider.notifier).filterByThreadId(threadId);
  }

  Widget _buildPromotionCard(
    BuildContext context,
    Promotion promotion,
    bool canEdit,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PromotionDetailScreen(promotionId: promotion.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (canEdit)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) => PromotionFormScreen(
                                      promotion: promotion,
                                    ),
                                  ),
                                )
                                .then((result) {
                                  if (result == true) {
                                    ref
                                        .read(promotionListProvider.notifier)
                                        .refresh();
                                  }
                                });
                          },
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await ConfirmationDialog.show(
                              context,
                              title: 'Delete Promotion',
                              message:
                                  'Are you sure you want to delete this promotion?',
                              confirmText: 'Delete',
                              isDestructive: true,
                            );

                            if (confirmed == true) {
                              try {
                                final repository = ref.read(
                                  promotionRepositoryProvider,
                                );
                                await repository.deletePromotion(promotion.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Promotion deleted successfully',
                                      ),
                                    ),
                                  );
                                  ref
                                      .read(promotionListProvider.notifier)
                                      .refresh();
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            }
                          },
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      promotion.gameName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final uri = Uri.parse(
                        'https://f95zone.to/threads/${promotion.threadId}',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Chip(
                      avatar: const Icon(Icons.open_in_new, size: 16),
                      label: Text('#${promotion.threadId}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Developer: ${promotion.devName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                promotion.reason,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (promotion.createdAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Created: ${promotion.createdAt!.toLocal()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final promotionsState = ref.watch(promotionListProvider);
    final authState = ref.watch(authStateProvider);
    final canCreate =
        authState.valueOrNull?.hasPermission('promotions.create') ?? false;
    final canEdit =
        authState.valueOrNull?.hasPermission('promotions.edit') ?? false;

    return MainLayout(
      title: 'Promotions',
      currentIndex: 3, // Promotions will be the fourth item in navigation
      actions: canCreate
          ? [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => const PromotionFormScreen(),
                        ),
                      )
                      .then((result) {
                        if (result == true) {
                          ref.read(promotionListProvider.notifier).refresh();
                        }
                      });
                },
                tooltip: 'Create New Promotion',
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
                    hintText: 'Search by game, developer, or reason...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _threadIdController,
                  decoration: const InputDecoration(
                    hintText: 'Filter by Thread ID...',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: _onThreadIdChanged,
                ),
              ],
            ),
          ),

          // Promotions list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: promotionsState.when(
                data: (promotions) {
                  if (promotions.isEmpty && !promotionsState.isLoading) {
                    return const Center(child: Text('No promotions found.'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount:
                        promotions.length +
                        (ref.read(promotionListProvider.notifier).isLoadingMore
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (index < promotions.length) {
                        final promotion = promotions[index];
                        return _buildPromotionCard(context, promotion, canEdit);
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
