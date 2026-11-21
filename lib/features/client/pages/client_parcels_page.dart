import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../features/parcels/controllers/my_parcels_controller.dart';

class ClientParcelsPage extends StatelessWidget {
  const ClientParcelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyParcelsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Mes colis')),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value != null) {
            return Center(child: Text(controller.errorMessage.value!));
          }
          if (controller.parcels.isEmpty) {
            return const Center(child: Text('Aucun colis pour le moment'));
          }
          return ListView.builder(
            itemCount: controller.parcels.length,
            itemBuilder: (context, index) {
              final parcel = controller.parcels[index];
              return Card(
                margin: const EdgeInsets.all(AppDimensions.sm),
                child: ListTile(
                  title: Text(parcel.trackingCode),
                  subtitle: Text('${parcel.departureAgency?.city ?? ''} → ${parcel.arrivalAgency?.city ?? ''}'),
                  trailing: Text(parcel.statusLabel),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}