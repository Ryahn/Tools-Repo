import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/features/games/models/game.dart';
import 'package:rule7_app/features/games/repositories/game_repository.dart';

/// Provider for GameRepository
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository();
});

/// State class for games list with pagination
class GamesListState {
  final List<Game> games;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final String? search;
  final String? status;
  final String? sort;

  GamesListState({
    this.games = const [],
    this.nextCursor,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
    this.search,
    this.status,
    this.sort = '-id',
  });

  GamesListState copyWith({
    List<Game>? games,
    String? nextCursor,
    bool? hasMore,
    bool? isLoading,
    String? error,
    String? search,
    String? status,
    String? sort,
  }) {
    return GamesListState(
      games: games ?? this.games,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      search: search ?? this.search,
      status: status ?? this.status,
      sort: sort ?? this.sort,
    );
  }
}

/// Notifier for managing games list state
class GamesListNotifier extends StateNotifier<GamesListState> {
  final GameRepository _repository;

  GamesListNotifier(this._repository) : super(GamesListState());

  /// Load games (first page)
  Future<void> loadGames({String? search, String? status, String? sort}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      search: search,
      status: status,
      sort: sort,
    );

    try {
      final response = await _repository.getGames(
        search: search ?? state.search,
        status: status ?? state.status,
        sort: sort ?? state.sort,
      );

      state = state.copyWith(
        games: response.games,
        nextCursor: response.nextCursor,
        hasMore: response.hasMore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load more games (next page)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.nextCursor == null) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final response = await _repository.getGames(
        cursor: state.nextCursor,
        search: state.search,
        status: state.status,
        sort: state.sort,
      );

      state = state.copyWith(
        games: [...state.games, ...response.games],
        nextCursor: response.nextCursor,
        hasMore: response.hasMore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh games list
  Future<void> refresh() async {
    await loadGames();
  }
}

/// Provider for GamesListNotifier
final gamesListProvider =
    StateNotifierProvider<GamesListNotifier, GamesListState>((ref) {
      final repository = ref.watch(gameRepositoryProvider);
      return GamesListNotifier(repository);
    });

/// Provider for fetching a single game
final gameProvider = FutureProvider.family<Game, int>((ref, id) async {
  final repository = ref.watch(gameRepositoryProvider);
  return await repository.getGame(id);
});
