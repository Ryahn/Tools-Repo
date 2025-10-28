import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/features/dashboard/models/dashboard_stats.dart';
import 'package:rule7_app/features/dashboard/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  // Use the singleton DioClient which has the auth interceptor
  return DashboardRepository();
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getDashboardStats();
});
