import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/features/promotions/models/promotion.dart';
import 'package:rule7_app/features/promotions/repositories/promotion_repository.dart';

final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  return PromotionRepository();
});

/// Provider for paginated promotion list
final promotionListProvider =
    NotifierProvider<PromotionListNotifier, AsyncValue<List<Promotion>>>(
      () => PromotionListNotifier(),
    );

class PromotionListNotifier extends Notifier<AsyncValue<List<Promotion>>> {
  String? _nextCursor;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _currentSearch;
  int? _currentThreadId;
  final String _currentSort = '-id';

  String? get nextCursor => _nextCursor;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  AsyncValue<List<Promotion>> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading || _isLoadingMore) return;

    _isLoadingMore = true;
    try {
      final repository = ref.read(promotionRepositoryProvider);
      final response = await repository.getPromotions(
        cursor: _nextCursor,
        search: _currentSearch,
        threadId: _currentThreadId,
        sort: _currentSort,
      );

      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;

      state = AsyncValue.data([...state.value ?? [], ...response.data]);
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
      final repository = ref.read(promotionRepositoryProvider);
      final response = await repository.getPromotions(
        cursor: null,
        search: _currentSearch,
        threadId: _currentThreadId,
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
      final repository = ref.read(promotionRepositoryProvider);
      final response = await repository.getPromotions(
        cursor: null,
        search: query,
        threadId: _currentThreadId,
        sort: _currentSort,
      );

      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;

      state = AsyncValue.data(response.data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> filterByThreadId(int? threadId) async {
    _currentThreadId = threadId;
    _nextCursor = null;
    _hasMore = true;

    try {
      final repository = ref.read(promotionRepositoryProvider);
      final response = await repository.getPromotions(
        cursor: null,
        search: _currentSearch,
        threadId: threadId,
        sort: _currentSort,
      );

      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;

      state = AsyncValue.data(response.data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// Provider for single promotion detail
final promotionProvider = FutureProvider.family<Promotion, int>((
  ref,
  id,
) async {
  final repository = ref.read(promotionRepositoryProvider);
  return repository.getPromotion(id);
});
