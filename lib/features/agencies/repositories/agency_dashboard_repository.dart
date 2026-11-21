import 'package:dio/dio.dart';

import '../models/agency_dashboard_data.dart';

/// Repository pour le tableau de bord opérationnel du responsable d'agence (V1-12).
class AgencyDashboardRepository {
  AgencyDashboardRepository(this._dio);

  final Dio _dio;

  Future<AgencyDashboardData> getOverview() async {
    final response = await _dio.get<Map<String, dynamic>>('/dashboard/overview');
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Réponse invalide.');
    return AgencyDashboardData.fromJson(data);
  }
}
