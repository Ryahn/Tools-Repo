import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rule7_app/features/dmca/providers/dmca_provider.dart';
import 'package:rule7_app/widgets/error_message.dart';
import 'package:rule7_app/widgets/loading_indicator.dart';

class DmcaDetailScreen extends ConsumerWidget {
  final int dmcaId;

  const DmcaDetailScreen({super.key, required this.dmcaId});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dmcaAsync = ref.watch(dmcaProvider(dmcaId));

    return Scaffold(
      appBar: AppBar(title: const Text('DMCA Details')),
      body: dmcaAsync.when(
        data: (dmca) => SingleChildScrollView(
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
                        dmca.gameName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Developer: ${dmca.devName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
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
                        'Game URL',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
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
                      if (dmca.updatedAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Updated: ${dmca.updatedAt!.toLocal()}',
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
          onRetry: () => ref.invalidate(dmcaProvider(dmcaId)),
        ),
      ),
    );
  }
}
