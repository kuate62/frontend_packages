import 'package:dio/dio.dart';

import '../models/trip.dart';

class TripsRepository {
  TripsRepository(this._dio);

  final Dio _dio;

  Future<List<Trip>> list({String? status, int page = 1, int limit = 50}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) params['status'] = status;
    final response = await _dio.get<Map<String, dynamic>>(
      '/trips',
      queryParameters: params,
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => Trip.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Trip> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/trips/$id');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final trip = data?['trip'] as Map<String, dynamic>?;
    if (trip == null) throw StateError('Trajet introuvable.');
    return Trip.fromJson(trip);
  }

  Future<List<Map<String, dynamic>>> listTripParcels(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/trips/$id/parcels');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.cast<Map<String, dynamic>>();
  }

  Future<void> loadParcel(String tripId, String parcelId) async {
    await _dio.post<Map<String, dynamic>>('/trips/$tripId/parcels/$parcelId/load');
  }

  Future<void> depart(String tripId) async {
    await _dio.post<Map<String, dynamic>>('/trips/$tripId/depart');
  }

  Future<void> arrive(String tripId) async {
    await _dio.post<Map<String, dynamic>>('/trips/$tripId/arrive');
  }

  Future<void> reportIncident(String parcelId, String type, String description) async {
    await _dio.post<Map<String, dynamic>>(
      '/parcels/$parcelId/incidents',
      data: <String, dynamic>{'type': type, 'description': description},
    );
  }

  Future<Trip> patch(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch<Map<String, dynamic>>('/trips/$id', data: payload);
    final data = response.data?['data'] as Map<String, dynamic>?;
    final trip = data?['trip'] as Map<String, dynamic>?;
    if (trip == null) throw StateError('Réponse invalide.');
    return Trip.fromJson(trip);
  }

  Future<Trip> create(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>('/trips', data: payload);
    final data = response.data?['data'] as Map<String, dynamic>?;
    final trip = data?['trip'] as Map<String, dynamic>?;
    if (trip == null) throw StateError('Réponse invalide.');
    return Trip.fromJson(trip);
  }

  Future<List<Map<String, dynamic>>> listAgencies() async {
    final response = await _dio.get<Map<String, dynamic>>('/agencies');
    final data = response.data?['data'] as Map<String, dynamic>?;
    return (data?['items'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> listVehicles() async {
    final response = await _dio.get<Map<String, dynamic>>('/vehicles');
    final data = response.data?['data'] as Map<String, dynamic>?;
    return (data?['items'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> listDrivers() async {
    final response = await _dio.get<Map<String, dynamic>>('/users');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items
        .cast<Map<String, dynamic>>()
        .where((u) {
          final memberships = u['memberships'] as List<dynamic>? ?? const [];
          return memberships.any((m) => (m as Map<String, dynamic>)['role'] == 'DRIVER');
        })
        .toList();
  }
}