import 'package:dio/dio.dart';

import '../models/customer.dart';

class CustomersRepository {
  CustomersRepository(this._dio);

  final Dio _dio;

  Future<List<Customer>> search(String query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/customers',
      queryParameters: <String, dynamic>{'search': query, 'limit': 20},
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => Customer.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Customer> create(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>('/customers', data: payload);
    final data = response.data?['data'] as Map<String, dynamic>?;
    final customer = data?['customer'] as Map<String, dynamic>?;
    if (customer == null) throw StateError('Réponse invalide.');
    return Customer.fromJson(customer);
  }
}