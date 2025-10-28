import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/features/auth/providers/auth_provider.dart';
import 'package:rule7_app/features/games/models/game.dart';
import 'package:rule7_app/features/games/providers/game_provider.dart';
import 'package:rule7_app/features/games/screens/game_detail_screen.dart';
import 'package:rule7_app/features/games/screens/game_form_screen.dart';
import 'package:rule7_app/shared/layouts/main_layout.dart';
import 'package:rule7_app/widgets/error_message.dart';
import 'package:rule7_app/widgets/loading_indicator.dart';

class GamesListScreen extends ConsumerStatefulWidget {
  const GamesListScreen({super.key});

  @override
  ConsumerState<GamesListScreen> createState() => _GamesListScreenState();
}

class _GamesListScreenState extends ConsumerState<GamesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial games
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gamesListProvider.notifier).loadGames();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Load more when scrolled to 90% of the list
      ref.read(gamesListProvider.notifier).loadMore();
    }
  }

  void _onSearch(String query) {
    ref.read(gamesListProvider.notifier).loadGames(search: query);
  }

  void _onStatusFilter(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    ref.read(gamesListProvider.notifier).loadGames(status: status);
  }

  Future<void> _onRefresh() async {
    await ref.read(gamesListProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final gamesState = ref.watch(gamesListProvider);
    final authState = ref.watch(authStateProvider);
    final canCreate =
        authState.valueOrNull?.hasPermission('games.create') ?? false;

    return MainLayout(
      title: 'Games',
      currentIndex: 1,
      actions: canCreate
          ? [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => const GameFormScreen(),
                        ),
                      )
                      .then((result) {
                        if (result == true) {
                          ref.read(gamesListProvider.notifier).refresh();
                        }
                      });
                },
                tooltip: 'Create New Game',
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
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search games...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: Icon(Icons.clear),
                  ),
                  onSubmitted: _onSearch,
                  onChanged: (value) {
                    if (value.isEmpty) _onSearch('');
                  },
                ),
                const SizedBox(height: 12),
                // Status filter
                Row(
                  children: [
                    const Text('Filter: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SegmentedButton<String?>(
                        segments: const [
                          ButtonSegment(value: null, label: Text('All')),
                          ButtonSegment(
                            value: 'approved',
                            label: Text('Approved'),
                          ),
                          ButtonSegment(value: 'banned', label: Text('Banned')),
                          ButtonSegment(
                            value: 'pending',
                            label: Text('Pending'),
                          ),
                        ],
                        selected: {_selectedStatus},
                        onSelectionChanged: (Set<String?> value) {
                          _onStatusFilter(value.first);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Games list
          Expanded(
            child: gamesState.error != null
                ? ErrorMessage(
                    message: gamesState.error!,
                    onRetry: () => _onRefresh(),
                  )
                : gamesState.games.isEmpty && gamesState.isLoading
                ? const LoadingIndicator(message: 'Loading games...')
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      itemCount:
                          gamesState.games.length +
                          (gamesState.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= gamesState.games.length) {
                          // Loading more indicator
                          return const LoadingIndicator();
                        }

                        final game = gamesState.games[index];
                        return _buildGameCard(context, game);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Game game) {
    final authState = ref.watch(authStateProvider);
    final canEdit = authState.valueOrNull?.hasPermission('games.edit') ?? false;

    Color statusColor;
    IconData statusIcon;

    switch (game.approved) {
      case 'approved':
        statusColor = Colors.greenAccent;
        statusIcon = Icons.check_circle;
        break;
      case 'banned':
        statusColor = Colors.redAccent;
        statusIcon = Icons.cancel;
        break;
      case 'pending':
        statusColor = Colors.orangeAccent;
        statusIcon = Icons.pending;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        title: Text(game.gameName),
        leading: canEdit
            ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => GameFormScreen(game: game),
                        ),
                      )
                      .then((result) {
                        if (result == true) {
                          ref.read(gamesListProvider.notifier).refresh();
                        }
                      });
                },
              )
            : const SizedBox.shrink(),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Author: ${game.author}'),
            if (game.gameNameJap != null) Text('Japanese: ${game.gameNameJap}'),
            if (game.createdAt != null)
              Text(
                'Created: ${game.createdAt!.toLocal().toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Icon(statusIcon, color: statusColor),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GameDetailScreen(gameId: game.id),
            ),
          );
        },
      ),
    );
  }
}
