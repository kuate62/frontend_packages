import 'package:dio/dio.dart';

import '../models/agent.dart';

class AgentsRepository {
  AgentsRepository(this._dio);

  final Dio _dio;

  Future<List<Agent>> list({int page = 1, int limit = 50}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/users',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => Agent.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Agent> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/users/$id');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final user = data?['user'] as Map<String, dynamic>?;
    if (user == null) throw StateError('Agent introuvable.');
    return Agent.fromJson(user);
  }

  Future<Agent> create(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>('/users', data: payload);
    final data = response.data?['data'] as Map<String, dynamic>?;
    final user = data?['user'] as Map<String, dynamic>?;
    if (user == null) throw StateError('Réponse invalide.');
    return Agent.fromJson(user);
  }

  Future<void> updateStatus(String id, String status) async {
    await _dio.patch<Map<String, dynamic>>(
      '/users/$id/status',
      data: <String, dynamic>{'status': status},
    );
  }

  Future<void> updateMembership(String membershipId, {String? role, String? status, String? agencyId}) async {
    final params = <String, dynamic>{};
    if (role != null) params['role'] = role;
    if (status != null) params['status'] = status;
    if (agencyId != null) params['agencyId'] = agencyId;
    await _dio.patch<Map<String, dynamic>>(
      '/memberships/$membershipId',
      data: params,
    );
  }
}