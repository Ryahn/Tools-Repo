import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/features/dmca/models/dmca.dart';
import 'package:rule7_app/features/dmca/repositories/dmca_repository.dart';

final dmcaRepositoryProvider = Provider<DmcaRepository>((ref) {
  return DmcaRepository();
});

/// Provider for paginated DMCA list
final dmcaListProvider =
    NotifierProvider<DmcaListNotifier, AsyncValue<List<Dmca>>>(
  () => DmcaListNotifier(),
);

class DmcaListNotifier extends Notifier<AsyncValue<List<Dmca>>> {
  String? _nextCursor;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _currentSearch;
  String? _currentSeverity;
  String _currentSort = '-id';

  String? get nextCursor => _nextCursor;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  AsyncValue<List<Dmca>> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading || _isLoadingMore) return;

    _isLoadingMore = true;
    try {
      final repository = ref.read(dmcaRepositoryProvider);
      final response = await repository.getDmcas(
        cursor: _nextCursor,
        search: _currentSearch,
        severity: _currentSeverity,
        sort: _currentSort,
      );

      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;

      state = AsyncValue.data([
        ...state.value ?? [],
        ...response.data,
      ]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    _nextCursor = null;
    _hasMore = true;

    try {
      final repository = ref.read(dmcaRepositoryProvider);
      final response = await repository.getDmcas(
        cursor: null,
        search: _currentSearch,
        severity: _currentSeverity,
        sort: _currentSort,
      );

      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;

      state = AsyncValue.data(response.data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> search(String query) async {
    _currentSearch = query;
    _nextCursor = null;
    _hasMore = true;

    try {
      final repository = ref.read(dmcaRepositoryProvider);
      final response = await repository.getDmcas(
        cursor: null,
        search: query,
        severity: _currentSeverity,
        sort: _currentSort,
      );

      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;

      state = AsyncValue.data(response.data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> filterBySeverity(String? severity) async {
    _currentSeverity = severity;
    _nextCursor = null;
    _hasMore = true;

    try {
      final repository = ref.read(dmcaRepositoryProvider);
      final response = await repository.getDmcas(
        cursor: null,
        search: _currentSearch,
        severity: severity,
        sort: _currentSort,
      );

      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;

      state = AsyncValue.data(response.data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> sort(String sort) async {
    _currentSort = sort;
    _nextCursor = null;
    _hasMore = true;

    try {
      final repository = ref.read(dmcaRepositoryProvider);
      final response = await repository.getDmcas(
        cursor: null,
        search: _currentSearch,
        severity: _currentSeverity,
        sort: sort,
      );

      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;

      state = AsyncValue.data(response.data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Provider for single DMCA detail
final dmcaProvider = FutureProvider.family<Dmca, int>((ref, id) async {
  final repository = ref.read(dmcaRepositoryProvider);
  return repository.getDmca(id);
});

