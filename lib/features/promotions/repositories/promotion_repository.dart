import 'package:rule7_app/core/api/dio_client.dart';
import 'package:rule7_app/features/promotions/models/promotion.dart';

class PromotionRepository {
  final DioClient _dio = DioClient.instance;

  PromotionRepository();

  /// Get paginated list of promotions
  Future<PromotionPaginatedResponse> getPromotions({
    String? cursor,
    int limit = 20,
    String? search,
    int? threadId,
    String? sort,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};

    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (threadId != null) {
      queryParams['thread_id'] = threadId;
    }

    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }

    final response = await _dio.dio.get(
      '/promotions',
      queryParameters: queryParams,
    );
    return PromotionPaginatedResponse.fromJson(response.data);
  }

  /// Get a single promotion by ID
  Future<Promotion> getPromotion(int id) async {
    final response = await _dio.dio.get('/promotions/$id');
    return Promotion.fromJson(response.data['data']);
  }

  /// Create a new promotion
  Future<Promotion> createPromotion(Map<String, dynamic> data) async {
    final response = await _dio.dio.post('/promotions', data: data);
    return Promotion.fromJson(response.data['data']);
  }

  /// Update an existing promotion
  Future<Promotion> updatePromotion(int id, Map<String, dynamic> data) async {
    final response = await _dio.dio.put('/promotions/$id', data: data);
    return Promotion.fromJson(response.data['data']);
  }

  /// Delete a promotion
  Future<void> deletePromotion(int id) async {
    await _dio.dio.delete('/promotions/$id');
  }
}
