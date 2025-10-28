import 'package:rule7_app/core/api/dio_client.dart';
import 'package:rule7_app/features/dmca/models/dmca.dart';

class DmcaRepository {
  final DioClient _dio = DioClient.instance;

  DmcaRepository();

  /// Get paginated list of DMCA entries
  Future<DmcaPaginatedResponse> getDmcas({
    String? cursor,
    int limit = 20,
    String? search,
    String? severity,
    String? sort,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };

    if (cursor != null && cursor.isNotEmpty) {
      queryParams['cursor'] = cursor;
    }

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (severity != null && severity.isNotEmpty) {
      queryParams['severity'] = severity;
    }

    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }

    final response = await _dio.dio.get('/dmca', queryParameters: queryParams);
    return DmcaPaginatedResponse.fromJson(response.data);
  }

  /// Get a single DMCA entry by ID
  Future<Dmca> getDmca(int id) async {
    final response = await _dio.dio.get('/dmca/$id');
    return Dmca.fromJson(response.data['data']);
  }

  /// Create a new DMCA entry
  Future<Dmca> createDmca(Map<String, dynamic> data) async {
    final response = await _dio.dio.post('/dmca', data: data);
    return Dmca.fromJson(response.data['data']);
  }

  /// Update an existing DMCA entry
  Future<Dmca> updateDmca(int id, Map<String, dynamic> data) async {
    final response = await _dio.dio.put('/dmca/$id', data: data);
    return Dmca.fromJson(response.data['data']);
  }

  /// Delete a DMCA entry
  Future<void> deleteDmca(int id) async {
    await _dio.dio.delete('/dmca/$id');
  }
}

