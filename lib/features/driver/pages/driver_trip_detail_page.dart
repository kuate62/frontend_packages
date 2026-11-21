import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../controllers/driver_controller.dart';

class DriverTripDetailPage extends StatefulWidget {
  const DriverTripDetailPage({super.key});

  @override
  State<DriverTripDetailPage> createState() => _DriverTripDetailPageState();
}

class _DriverTripDetailPageState extends State<DriverTripDetailPage> {
  @override
  void initState() {
    super.initState();
    final id = Get.arguments as String?;
    if (id != null) Get.find<DriverController>().openTrip(id);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Trajet')),
      body: Obx(() {
        final trip = controller.selectedTrip.value;
        if (trip == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Statut : ${trip['status']}'),
              Text('Colis : ${controller.tripParcels.length}'),
              Text('Chargés : ${controller.tripParcels.where((p) => p['loadedAt'] != null).length}'),
              const SizedBox(height: AppDimensions.sm),
              if (controller.tripParcels.isEmpty)
                const Expanded(child: Center(child: Text('Manifeste vide')))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.tripParcels.length,
                    itemBuilder: (context, index) {
                      final parcel = controller.tripParcels[index];
                      return ListTile(
                        title: Text(parcel['trackingCode']?.toString() ?? ''),
                        subtitle: Text(parcel['loadedAt'] == null ? 'Non chargé' : 'Chargé'),
                        trailing: IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => controller.loadParcel(trip['id'] as String, parcel['id'] as String),
                        ),
                      );
                    },
                  ),
                ),
              ElevatedButton(
                onPressed: () => controller.depart(trip['id'] as String),
                child: const Text('Départ'),
              ),
              ElevatedButton(
                onPressed: () => controller.arrive(trip['id'] as String),
                child: const Text('Arrivée'),
              ),
            ],
          ),
        );
      }),
    );
  }
}