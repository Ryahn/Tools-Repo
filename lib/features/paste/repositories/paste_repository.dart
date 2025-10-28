import 'package:rule7_app/core/api/dio_client.dart';
import 'package:rule7_app/features/paste/models/paste.dart';

class PasteRepository {
  final DioClient _dio = DioClient.instance;

  PasteRepository();

  /// Create a new paste
  Future<Paste> createPaste(Map<String, dynamic> data) async {
    final response = await _dio.dio.post('/paste', data: data);
    return Paste.fromJson(response.data['data']);
  }

  /// Get a single paste by slug
  Future<Paste> getPaste(String slug) async {
    final response = await _dio.dio.get('/paste/$slug');
    return Paste.fromJson(response.data['data']);
  }
}
