import 'package:dio/dio.dart';

class ParcelsRepository {
  ParcelsRepository(this._dio);

  final Dio _dio;

  Dio get dio => _dio;

  Future<Map<String, dynamic>> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/parcels/$id');
    return response.data?['data']?['parcel'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> list({
    String? status,
    String? trackingCode,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) params['status'] = status;
    if (trackingCode != null && trackingCode.trim().isNotEmpty) params['trackingCode'] = trackingCode.trim();
    final response = await _dio.get<Map<String, dynamic>>('/parcels', queryParameters: params);
    final data = response.data?['data'] as Map<String, dynamic>?;
    return (data?['items'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> events(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/parcels/$id/events');
    final data = response.data?['data'] as Map<String, dynamic>?;
    return (data?['items'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> receive(String id) async {
    final response = await _dio.post<Map<String, dynamic>>('/parcels/$id/receive');
    return response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> deliver(String id, String code) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/parcels/$id/deliver',
      data: <String, dynamic>{'code': code},
    );
    return response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> returnParcel(String id, String comment) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/parcels/$id/return',
      data: <String, dynamic>{'comment': comment},
    );
    return response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> payments(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/payments/parcel/$id');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.cast<Map<String, dynamic>>();
  }
}