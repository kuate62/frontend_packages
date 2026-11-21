import 'package:dio/dio.dart';

class PaymentsRepository {
  PaymentsRepository(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> createPayment({
    required String parcelId,
    required double amount,
    required String mode,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/payments',
      data: <String, dynamic>{
        'parcelId': parcelId,
        'amount': amount,
        'mode': mode,
      },
    );
    return response.data?['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
  }
}