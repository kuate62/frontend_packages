import 'package:dio/dio.dart';

import '../models/tenant.dart';

class TenantsRepository {
  TenantsRepository(this._dio);

  final Dio _dio;

  Future<Tenant> setStatus(String id, String status) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/tenants/$id/status',
      data: <String, dynamic>{'status': status},
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    final tenant = data?['tenant'] as Map<String, dynamic>?;
    if (tenant == null) throw StateError('Réponse invalide.');
    return Tenant.fromJson(tenant);
  }

  Future<List<Tenant>> list({int page = 1, int limit = 50}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tenants',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => Tenant.fromJson(item as Map<String, dynamic>)).toList();
  }
}