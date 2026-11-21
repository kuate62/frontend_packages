import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/agencies_controller.dart';

class AgenciesPage extends GetView<AgenciesController> {
  const AgenciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agences')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.agencyCreate),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!));
        }
        if (controller.agencies.isEmpty) {
          return const Center(child: Text('Aucune agence'));
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.builder(
            itemCount: controller.agencies.length,
            itemBuilder: (context, index) {
              final agency = controller.agencies[index];
              return Card(
                margin: const EdgeInsets.all(AppDimensions.sm),
                child: ListTile(
                  title: Text(agency.name),
                  subtitle: Text('${agency.code} - ${agency.city ?? ''}'),
                  trailing: Text(agency.status),
                  onTap: () => Get.toNamed(AppRoutes.agencyDetail, arguments: agency.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}