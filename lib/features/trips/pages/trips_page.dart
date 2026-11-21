import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/trips_controller.dart';

class TripsPage extends GetView<TripsController> {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trajets')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.tripCreate),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.sm),
            child: Obx(() => Wrap(
                  spacing: AppDimensions.xs,
                  children: [
                    FilterChip(
                      label: const Text('Tous'),
                      selected: controller.statusFilter.value == null,
                      onSelected: (_) => controller.load(status: null),
                    ),
                    FilterChip(
                      label: const Text('Planifiés'),
                      selected: controller.statusFilter.value == 'PLANNED',
                      onSelected: (_) => controller.load(status: 'PLANNED'),
                    ),
                    FilterChip(
                      label: const Text('En cours'),
                      selected: controller.statusFilter.value == 'IN_TRANSIT',
                      onSelected: (_) => controller.load(status: 'IN_TRANSIT'),
                    ),
                    FilterChip(
                      label: const Text('Arrivés'),
                      selected: controller.statusFilter.value == 'ARRIVED',
                      onSelected: (_) => controller.load(status: 'ARRIVED'),
                    ),
                    FilterChip(
                      label: const Text('Annulés'),
                      selected: controller.statusFilter.value == 'CANCELLED',
                      onSelected: (_) => controller.load(status: 'CANCELLED'),
                    ),
                  ],
                )),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value != null) {
                return Center(child: Text(controller.errorMessage.value!));
              }
              if (controller.trips.isEmpty) {
                return const Center(child: Text('Aucun trajet'));
              }
              return RefreshIndicator(
                onRefresh: () => controller.load(status: controller.statusFilter.value),
                child: ListView.builder(
                  itemCount: controller.trips.length,
                  itemBuilder: (context, index) {
                    final trip = controller.trips[index];
                    return Card(
                      margin: const EdgeInsets.all(AppDimensions.sm),
                      child: ListTile(
                        title: Text('${trip.departureAgency ?? ''} → ${trip.arrivalAgency ?? ''}'),
                        subtitle: Text(trip.plannedDepartureAt ?? ''),
                        trailing: Text(trip.status),
                        onTap: () => Get.toNamed(AppRoutes.tripDetail, arguments: trip.id),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}