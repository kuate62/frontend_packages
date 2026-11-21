import 'package:dio/dio.dart';

import '../models/app_user.dart';

/// Repository pour la gestion globale des utilisateurs (SUPER_ADMIN).
class UsersRepository {
  UsersRepository(this._dio);

  final Dio _dio;

  /// Liste globale paginée avec filtres.
  Future<Map<String, dynamic>> list({
    String? search,
    String? tenantId,
    String? role,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (tenantId != null && tenantId.isNotEmpty) params['tenantId'] = tenantId;
    if (role != null && role.isNotEmpty) params['role'] = role;
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await _dio.get<Map<String, dynamic>>(
      '/users',
      queryParameters: params,
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Réponse invalide.');
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
        .toList();
    return {
      'items': items,
      'total': data['total'] as int? ?? 0,
      'page': data['page'] as int? ?? page,
      'limit': data['limit'] as int? ?? limit,
    };
  }

  /// Détail d'un utilisateur.
  Future<AppUser> getUser(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/users/$id');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final user = data?['user'] as Map<String, dynamic>?;
    if (user == null) throw StateError('Réponse invalide.');
    return AppUser.fromJson(user);
  }

  /// Modification du statut global d'un utilisateur.
  Future<AppUser> setUserStatus(String id, String status) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/$id/status',
      data: <String, dynamic>{'status': status},
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    final user = data?['user'] as Map<String, dynamic>?;
    if (user == null) throw StateError('Réponse invalide.');
    return AppUser.fromJson(user);
  }
}
