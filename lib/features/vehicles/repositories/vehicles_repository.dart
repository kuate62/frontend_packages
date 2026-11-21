import 'package:dio/dio.dart';

import '../models/vehicle.dart';

class VehiclesRepository {
  VehiclesRepository(this._dio);

  final Dio _dio;

  Future<List<Vehicle>> list({String? status, int page = 1, int limit = 50}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) params['status'] = status;
    final response = await _dio.get<Map<String, dynamic>>('/vehicles', queryParameters: params);
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => Vehicle.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Vehicle> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/vehicles/$id');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final vehicle = data?['vehicle'] as Map<String, dynamic>?;
    if (vehicle == null) throw StateError('Véhicule introuvable.');
    return Vehicle.fromJson(vehicle);
  }

  Future<Vehicle> create(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>('/vehicles', data: payload);
    final data = response.data?['data'] as Map<String, dynamic>?;
    final vehicle = data?['vehicle'] as Map<String, dynamic>?;
    if (vehicle == null) throw StateError('Réponse invalide.');
    return Vehicle.fromJson(vehicle);
  }

  Future<Vehicle> update(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Map<String, dynamic>>('/vehicles/$id', data: payload);
    final data = response.data?['data'] as Map<String, dynamic>?;
    final vehicle = data?['vehicle'] as Map<String, dynamic>?;
    if (vehicle == null) throw StateError('Réponse invalide.');
    return Vehicle.fromJson(vehicle);
  }

  Future<Vehicle> deactivate(String id) async {
    final response = await _dio.patch<Map<String, dynamic>>('/vehicles/$id/deactivate');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final vehicle = data?['vehicle'] as Map<String, dynamic>?;
    if (vehicle == null) throw StateError('Réponse invalide.');
    return Vehicle.fromJson(vehicle);
  }
}