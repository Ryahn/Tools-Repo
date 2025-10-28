import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rule7_app/features/games/providers/game_provider.dart';
import 'package:rule7_app/widgets/error_message.dart';
import 'package:rule7_app/widgets/loading_indicator.dart';

class GameDetailScreen extends ConsumerWidget {
  final int gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(gameProvider(gameId));

    return Scaffold(
      appBar: AppBar(title: const Text('Game Details')),
      body: gameAsync.when(
        data: (game) => _buildContent(context, game),
        loading: () => const LoadingIndicator(message: 'Loading game...'),
        error: (error, stack) => ErrorMessage(message: error.toString()),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic game) {
    Color statusColor;
    String statusLabel;

    switch (game.approved) {
      case 'approved':
        statusColor = Colors.greenAccent;
        statusLabel = 'Approved';
        break;
      case 'banned':
        statusColor = Colors.redAccent;
        statusLabel = 'Banned';
        break;
      case 'pending':
        statusColor = Colors.orangeAccent;
        statusLabel = 'Pending';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = 'Unknown';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          // Game name
          Text(
            game.gameName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),

          // Author
          Text(
            'Author: ${game.author}',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          if (game.gameNameJap != null) ...[
            const SizedBox(height: 8),
            Text(
              'Japanese: ${game.gameNameJap}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],

          if (game.gameNameRomaji != null) ...[
            const SizedBox(height: 8),
            Text(
              'Romaji: ${game.gameNameRomaji}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],

          const Divider(height: 32),

          // Reason
          Text('Reason', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(game.reason),

          const Divider(height: 32),

          // Ruling
          Text('Ruling', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(game.ruling),

          // Links section
          if (_hasLinks(game)) ...[
            const Divider(height: 32),
            Text('Links', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildLinkButton(context, 'Steam', game.steamLink),
            _buildLinkButton(context, 'DLsite', game.dlsiteLink),
            _buildLinkButton(context, 'Itch.io', game.itchLink),
            _buildLinkButton(context, 'Patreon', game.patreonLink),
            _buildLinkButton(context, 'SubscribeStar', game.subscribestarLink),
            _buildLinkButton(context, 'JAST', game.jastLink),
            _buildLinkButton(context, 'VNDB', game.vndbLink),
            _buildLinkButton(context, 'ExHentai', game.exhentaiLink),
            _buildLinkButton(context, 'E-Hentai', game.egahentaiLink),
            _buildLinkButton(context, 'nHentai', game.nhentaiLink),
            _buildLinkButton(context, 'MangaGamer', game.mangagamerLink),
            _buildLinkButton(context, 'Other', game.othersLink),
          ],
        ],
      ),
    );
  }

  bool _hasLinks(dynamic game) {
    return game.steamLink != null ||
        game.dlsiteLink != null ||
        game.itchLink != null ||
        game.patreonLink != null ||
        game.subscribestarLink != null ||
        game.jastLink != null ||
        game.vndbLink != null ||
        game.exhentaiLink != null ||
        game.egahentaiLink != null ||
        game.nhentaiLink != null ||
        game.mangagamerLink != null ||
        game.othersLink != null;
  }

  Widget _buildLinkButton(BuildContext context, String label, String? url) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: const Icon(Icons.open_in_new),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 40),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // Handle error
    }
  }
}
