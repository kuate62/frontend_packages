import 'package:dio/dio.dart';

import '../models/super_admin_dashboard_data.dart';

/// Repository pour le tableau de bord général Super Administrateur.
class SuperAdminDashboardRepository {
  SuperAdminDashboardRepository(this._dio);

  final Dio _dio;

  Future<SuperAdminDashboardData> getDashboard() async {
    final response = await _dio.get<Map<String, dynamic>>('/dashboard/super-admin');
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Réponse invalide.');
    return SuperAdminDashboardData.fromJson(data);
  }
}
