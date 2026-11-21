import 'package:dio/dio.dart';

import '../models/notification.dart';

class NotificationsRepository {
  NotificationsRepository(this._dio);

  final Dio _dio;

  Future<List<AppNotification>> list({int page = 1, int limit = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? const [];
    return items.map((item) => AppNotification.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<int> unreadCount() async {
    final response = await _dio.get<Map<String, dynamic>>('/notifications/unread-count');
    final data = response.data?['data'] as Map<String, dynamic>?;
    return data?['count'] as int? ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _dio.patch<Map<String, dynamic>>('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.patch<Map<String, dynamic>>('/notifications/read-all');
  }
}