import 'package:dio/dio.dart';

import '../models/company_dashboard_data.dart';

/// Repository pour le tableau de bord de l'administrateur d'entreprise.
class CompanyDashboardRepository {
  CompanyDashboardRepository(this._dio);

  final Dio _dio;

  Future<CompanyDashboardData> getOverview() async {
    final response = await _dio.get<Map<String, dynamic>>('/dashboard/overview');
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Réponse invalide.');
    return CompanyDashboardData.fromJson(data);
  }
}
