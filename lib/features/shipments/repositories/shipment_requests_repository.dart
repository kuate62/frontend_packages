import 'package:dio/dio.dart';

import '../models/shipment_request.dart';

class ShipmentRequestsRepository {
  ShipmentRequestsRepository(this._dio);

  final Dio _dio;

  Future<ShipmentRequest> create(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/shipment-requests',
      data: payload,
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Réponse invalide.');
    }
    return ShipmentRequest.fromJson(data);
  }

  Future<List<ShipmentRequest>> listCompany({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) {
      params['status'] = status;
    }
    final response = await _dio.get<Map<String, dynamic>>(
      '/shipment-requests/company',
      queryParameters: params,
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => ShipmentRequest.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<ShipmentRequest> accept(String id) async {
    final response = await _dio.post<Map<String, dynamic>>('/shipment-requests/company/$id/accept');
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Réponse invalide.');
    return ShipmentRequest.fromJson(data);
  }

  Future<ShipmentRequest> reject(String id, String reason) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/shipment-requests/company/$id/reject',
      data: <String, dynamic>{'reason': reason},
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) throw StateError('Réponse invalide.');
    return ShipmentRequest.fromJson(data);
  }

  Future<Map<String, dynamic>> pay(String id) async {
    final response = await _dio.post<Map<String, dynamic>>('/shipment-requests/$id/pay');
    return response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<List<ShipmentRequest>> list() async {
    final response = await _dio.get<Map<String, dynamic>>('/shipment-requests');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => ShipmentRequest.fromJson(item as Map<String, dynamic>)).toList();
  }
}