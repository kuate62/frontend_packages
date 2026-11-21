import 'package:dio/dio.dart';

import '../models/directory_models.dart';

class DirectoryRepository {
  DirectoryRepository(this._dio);

  final Dio _dio;

  Future<List<Company>> listCompanies({
    String? search,
    String? city,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/directory/companies',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => Company.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>?> quoteCompany(
    String companyId, {
    required double weightKg,
    double? distanceKm,
    bool fragile = false,
    double? declaredValue,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/directory/companies/$companyId/quote',
      data: <String, dynamic>{
        'weightKg': weightKg,
        'distanceKm': distanceKm,
        'fragile': fragile,
        'declaredValue': declaredValue,
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return data;
  }

  Future<List<Agency>> listAgencies({
    String? search,
    String? city,
    String? tenantId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/directory/agencies',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        if (tenantId != null && tenantId.trim().isNotEmpty) 'tenantId': tenantId.trim(),
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => Agency.fromJson(item as Map<String, dynamic>)).toList();
  }
}