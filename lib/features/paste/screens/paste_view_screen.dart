import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/features/paste/providers/paste_provider.dart';
import 'package:rule7_app/widgets/error_message.dart';
import 'package:rule7_app/widgets/loading_indicator.dart';
import 'package:rule7_app/shared/layouts/main_layout.dart';
import 'package:url_launcher/url_launcher.dart';

/// Paste View Screen
class PasteViewScreen extends ConsumerWidget {
  final String pasteSlug;

  const PasteViewScreen({super.key, required this.pasteSlug});

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pasteAsync = ref.watch(pasteProvider(pasteSlug));

    return MainLayout(
      title: 'Paste #$pasteSlug',
      currentIndex: 4,
      actions: [
        pasteAsync.when(
          data: (paste) => IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyToClipboard(context, paste.content),
            tooltip: 'Copy to clipboard',
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        pasteAsync.when(
          data: (paste) => IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              // Share the paste URL
              final uri = Uri.parse('${Uri.base.origin}/paste/$pasteSlug');
              final uriLaunch = Uri(
                scheme: 'mailto',
                queryParameters: {
                  'subject': 'Shared Paste',
                  'body': 'Check out this paste: ${uri.toString()}',
                },
              );
              if (await canLaunchUrl(uriLaunch)) {
                await launchUrl(uriLaunch);
              }
            },
            tooltip: 'Share paste',
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
      body: pasteAsync.when(
        data: (paste) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text('Language: ${paste.language}'),
                            avatar: const Icon(Icons.code, size: 18),
                          ),
                          if (paste.private)
                            Chip(
                              label: const Text('Private'),
                              avatar: const Icon(Icons.lock, size: 18),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                            ),
                          if (paste.expiresAt != null)
                            Chip(
                              label: Text(
                                'Expires: ${paste.expiresAt!.toLocal()}',
                              ),
                              avatar: const Icon(Icons.schedule, size: 18),
                            ),
                        ],
                      ),
                      if (paste.createdAt != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Created: ${paste.createdAt!.toLocal()}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Content
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Content',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                            onPressed: () =>
                                _copyToClipboard(context, paste.content),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          paste.content,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
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
          onRetry: () => ref.invalidate(pasteProvider(pasteSlug)),
        ),
      ),
    );
  }
}
