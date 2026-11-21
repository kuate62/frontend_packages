import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/claims_controller.dart';


class ClaimsPage extends GetView<ClaimsController> {
  const ClaimsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes réclamations')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/claims/create'),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!));
        }
        if (controller.claims.isEmpty) {
          return const Center(child: Text('Aucune réclamation'));
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.builder(
            itemCount: controller.claims.length,
            itemBuilder: (context, index) {
              final claim = controller.claims[index];
              return Card(
                margin: const EdgeInsets.all(AppDimensions.sm),
                child: ListTile(
                  title: Text(claim.subject),
                  subtitle: Text('${claim.reference} - ${claim.status}'),
                  onTap: () => Get.toNamed(AppRoutes.claimDetail, arguments: claim.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}