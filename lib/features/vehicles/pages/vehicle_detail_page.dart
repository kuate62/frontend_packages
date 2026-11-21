import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../controllers/vehicles_controller.dart';


class VehicleDetailPage extends StatelessWidget {
  const VehicleDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String?;
    final controller = Get.find<VehiclesController>();
    final vehicle = controller.vehicles.firstWhereOrNull((v) => v.id == id);
    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Véhicule')),
        body: const Center(child: Text('Véhicule introuvable')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(vehicle.plate)),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type : ${vehicle.type ?? ''}'),
            Text('Capacité : ${vehicle.capacityKg ?? ''} ${vehicle.capacityUnit ?? ''}'),
            Text('Statut : ${vehicle.status}'),
            if (vehicle.description != null) Text('Description : ${vehicle.description}'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vehicle.isActive ? () => controller.deactivate(vehicle.id) : null,
                child: Text(vehicle.isActive ? 'Désactiver' : 'Désactivé'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}