import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/vehicles_controller.dart';


class VehiclesPage extends GetView<VehiclesController> {
  const VehiclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Véhicules')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.vehicleCreate),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!));
        }
        if (controller.vehicles.isEmpty) {
          return const Center(child: Text('Aucun véhicule'));
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.builder(
            itemCount: controller.vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = controller.vehicles[index];
              return Card(
                margin: const EdgeInsets.all(AppDimensions.sm),
                child: ListTile(
                  title: Text(vehicle.plate),
                  subtitle: Text('${vehicle.type ?? ''} - ${vehicle.capacityKg ?? ''} kg'),
                  trailing: Text(vehicle.status),
                  onTap: () => Get.toNamed(AppRoutes.vehicleDetail, arguments: vehicle.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}