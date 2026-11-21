import 'package:dio/dio.dart';

import '../models/my_parcel.dart';

class MyParcelsRepository {
  MyParcelsRepository(this._dio);

  final Dio _dio;

  Future<List<MyParcel>> listMyParcels() async {
    final response = await _dio.get<Map<String, dynamic>>('/my/parcels');
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => MyParcel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<MyParcel> getMyParcel(String identifier) async {
    final response = await _dio.get<Map<String, dynamic>>('/my/parcels/$identifier');
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Colis introuvable.');
    }
    return MyParcel.fromJson(data);
  }
}