import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/parcels_controller.dart';

class ParcelsPage extends GetView<ParcelsController> {
  const ParcelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Colis')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher par code',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) => controller.load(trackingCode: value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: Obx(() => Wrap(
                  spacing: AppDimensions.xs,
                  children: [
                    FilterChip(
                      label: const Text('Tous'),
                      selected: controller.statusFilter.value == null,
                      onSelected: (_) => controller.load(status: null),
                    ),
                    FilterChip(
                      label: const Text('Enregistré'),
                      selected: controller.statusFilter.value == 'REGISTERED',
                      onSelected: (_) => controller.load(status: 'REGISTERED'),
                    ),
                    FilterChip(
                      label: const Text('En transit'),
                      selected: controller.statusFilter.value == 'IN_TRANSIT',
                      onSelected: (_) => controller.load(status: 'IN_TRANSIT'),
                    ),
                    FilterChip(
                      label: const Text('Livré'),
                      selected: controller.statusFilter.value == 'DELIVERED',
                      onSelected: (_) => controller.load(status: 'DELIVERED'),
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
              if (controller.parcels.isEmpty) {
                return const Center(child: Text('Aucun colis'));
              }
              return RefreshIndicator(
                onRefresh: () => controller.load(status: controller.statusFilter.value, trackingCode: controller.searchQuery.value),
                child: ListView.builder(
                  itemCount: controller.parcels.length,
                  itemBuilder: (context, index) {
                    final parcel = controller.parcels[index];
                    return Card(
                      margin: const EdgeInsets.all(AppDimensions.sm),
                      child: ListTile(
                        title: Text(parcel['trackingCode'] as String? ?? ''),
                        subtitle: Text(parcel['status'] as String? ?? ''),
                        onTap: () => Get.toNamed(AppRoutes.parcelDetail, arguments: parcel['id']),
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