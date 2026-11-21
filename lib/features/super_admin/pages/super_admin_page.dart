import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';

import '../../../core/theme/app_dimensions.dart';
import '../controllers/super_admin_controller.dart';

class SuperAdminPage extends GetView<SuperAdminController> {
  const SuperAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super administrateur'),
        actions: [
          IconButton(
            key: const Key('nav_to_dashboard_button'),
            icon: const Icon(Icons.dashboard),
            tooltip: 'Tableau de bord',
            onPressed: () => Get.toNamed(AppRoutes.superAdminDashboard),
          ),
          IconButton(
            key: const Key('nav_to_users_button'),
            icon: const Icon(Icons.people),
            tooltip: 'Utilisateurs',
            onPressed: () => Get.toNamed(AppRoutes.superAdminUsers),
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
        return ListView.builder(
          itemCount: controller.tenants.length,
          itemBuilder: (context, index) {
            final tenant = controller.tenants[index];
            return Card(
              margin: const EdgeInsets.all(AppDimensions.sm),
              child: ListTile(
                title: Text(tenant.name),
                subtitle: Text(tenant.city ?? ''),
                trailing: Text(tenant.status ?? ''),
                onTap: () => Get.toNamed(AppRoutes.superAdminDetail, arguments: tenant.id),
              ),
            );
          },
        );
      }),
    );
  }
}