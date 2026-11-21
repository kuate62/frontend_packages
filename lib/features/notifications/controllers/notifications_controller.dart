import 'package:get/get.dart';


import '../models/notification.dart';
import '../repositories/notifications_repository.dart';

class NotificationsController extends GetxController {
  NotificationsController(this._repository);

  final NotificationsRepository _repository;

  final notifications = <AppNotification>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      notifications.assignAll(await _repository.list());
      unreadCount.value = await _repository.unreadCount();
    } catch (_) {
      errorMessage.value = 'Impossible de charger les notifications.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      final index = notifications.indexWhere((item) => item.id == id);
      if (index != -1) {
        final current = notifications[index];
        notifications[index] = AppNotification(
          id: current.id,
          type: current.type,
          title: current.title,
          message: current.message,
          data: current.data,
          isRead: true,
          createdAt: current.createdAt,
        );
      }
      if (unreadCount.value > 0) unreadCount.value--;
    } catch (_) {
      errorMessage.value = 'Impossible de marquer comme lu.';
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      notifications.assignAll(notifications.map((item) => AppNotification(
            id: item.id,
            type: item.type,
            title: item.title,
            message: item.message,
            data: item.data,
            isRead: true,
            createdAt: item.createdAt,
          )));
      unreadCount.value = 0;
    } catch (_) {
      errorMessage.value = 'Impossible de marquer toutes comme lues.';
    }
  }
}