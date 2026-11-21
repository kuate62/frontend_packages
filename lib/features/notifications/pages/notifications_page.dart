import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';

import '../../../core/theme/app_text_styles.dart';
import '../controllers/notifications_controller.dart';

class NotificationsPage extends GetView<NotificationsController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: controller.markAllAsRead,
            child: const Text('Tout lire'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!));
        }
        if (controller.notifications.isEmpty) {
          return const Center(child: Text('Aucune notification'));
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.builder(
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final item = controller.notifications[index];
              return ListTile(
                leading: Icon(
                  item.isRead ? Icons.notifications_none : Icons.notifications,
                  color: item.isRead ? AppColors.textSecondary : AppColors.primary,
                ),
                title: Text(item.title, style: AppTextStyles.label),
                subtitle: Text(item.message),
                onTap: () => controller.markAsRead(item.id),
              );
            },
          ),
        );
      }),
    );
  }
}