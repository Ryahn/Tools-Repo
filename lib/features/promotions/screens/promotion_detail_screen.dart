import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rule7_app/features/promotions/providers/promotion_provider.dart';
import 'package:rule7_app/widgets/error_message.dart';
import 'package:rule7_app/widgets/loading_indicator.dart';

class PromotionDetailScreen extends ConsumerWidget {
  final int promotionId;

  const PromotionDetailScreen({super.key, required this.promotionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotionAsync = ref.watch(promotionProvider(promotionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Promotion Details')),
      body: promotionAsync.when(
        data: (promotion) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promotion.gameName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Developer: ${promotion.devName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: Text('Thread #${promotion.threadId}'),
                        onPressed: () async {
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
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reason',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(promotion.reason),
                      if (promotion.createdAt != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Created: ${promotion.createdAt!.toLocal()}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (promotion.updatedAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Updated: ${promotion.updatedAt!.toLocal()}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const LoadingIndicator(),
        error: (error, stack) => ErrorMessage(
          message: error.toString(),
          onRetry: () => ref.invalidate(promotionProvider(promotionId)),
        ),
      ),
    );
  }
}
