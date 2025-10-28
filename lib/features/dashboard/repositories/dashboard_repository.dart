import 'package:dio/dio.dart';
import 'package:rule7_app/core/api/dio_client.dart';
import 'package:rule7_app/features/dashboard/models/dashboard_stats.dart';

class DashboardRepository {
  final Dio _dio;

  DashboardRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  /// Fetch dashboard statistics
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _dio.get('/stats/dashboard');

      if (response.statusCode == 200) {
        return DashboardStats.fromJson(response.data);
      }

      throw Exception('Failed to load dashboard statistics');
    } catch (e) {
      throw Exception('Failed to load dashboard statistics: $e');
    }
  }

  /// Fetch recent activity
  Future<Map<String, dynamic>> getRecentActivity() async {
    try {
      final response = await _dio.get('/stats/activity');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('Failed to load recent activity');
    } catch (e) {
      throw Exception('Failed to load recent activity: $e');
    }
  }
}
