import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/driver_controller.dart';

class DriverTripsPage extends GetView<DriverController> {
  const DriverTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes trajets')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!));
        }
        if (controller.trips.isEmpty) {
          return const Center(child: Text('Aucun trajet'));
        }
        return ListView.builder(
          itemCount: controller.trips.length,
          itemBuilder: (context, index) {
            final trip = controller.trips[index];
            return Card(
              margin: const EdgeInsets.all(AppDimensions.sm),
              child: ListTile(
                title: Text('${trip['departure']} → ${trip['arrival']}'),
                subtitle: Text(trip['departureAt']?.toString() ?? ''),
                trailing: Text(trip['status']?.toString() ?? ''),
                onTap: () => Get.toNamed(AppRoutes.driverTripDetail, arguments: trip['id']),
              ),
            );
          },
        );
      }),
    );
  }
}