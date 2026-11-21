import 'package:dio/dio.dart';

import '../models/agency.dart';

class AgenciesRepository {
  AgenciesRepository(this._dio);

  final Dio _dio;

  Future<List<Agency>> list({int page = 1, int limit = 50}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/agencies',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => Agency.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Agency> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/agencies/$id');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final agency = data?['agency'] as Map<String, dynamic>?;
    if (agency == null) throw StateError('Agence introuvable.');
    return Agency.fromJson(agency);
  }

  Future<Agency> create(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>('/agencies', data: payload);
    final data = response.data?['data'] as Map<String, dynamic>?;
    final agency = data?['agency'] as Map<String, dynamic>?;
    if (agency == null) throw StateError('Réponse invalide.');
    return Agency.fromJson(agency);
  }

  Future<Agency> update(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Map<String, dynamic>>('/agencies/$id', data: payload);
    final data = response.data?['data'] as Map<String, dynamic>?;
    final agency = data?['agency'] as Map<String, dynamic>?;
    if (agency == null) throw StateError('Réponse invalide.');
    return Agency.fromJson(agency);
  }

  Future<Agency> deactivate(String id) async {
    final response = await _dio.delete<Map<String, dynamic>>('/agencies/$id');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final agency = data?['agency'] as Map<String, dynamic>?;
    if (agency == null) throw StateError('Réponse invalide.');
    return Agency.fromJson(agency);
  }
}