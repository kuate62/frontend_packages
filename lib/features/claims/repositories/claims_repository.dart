import 'package:dio/dio.dart';

import '../models/claim.dart';

class ClaimsRepository {
  ClaimsRepository(this._dio);

  final Dio _dio;

  Future<List<Claim>> listMyClaims() async {
    final response = await _dio.get<Map<String, dynamic>>('/my/claims');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => Claim.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Claim> getMyClaim(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/my/claims/$id');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final claim = data?['claim'] as Map<String, dynamic>?;
    if (claim == null) throw StateError('Réclamation introuvable.');
    return Claim.fromJson(claim);
  }

  Future<List<Map<String, dynamic>>> getHistory(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/my/claims/$id/history');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<Claim> createClaim(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>('/my/claims', data: payload);
    final data = response.data?['data'] as Map<String, dynamic>?;
    final claim = data?['claim'] as Map<String, dynamic>?;
    if (claim == null) throw StateError('Réponse invalide.');
    return Claim.fromJson(claim);
  }
}