import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';

import '../../../core/theme/app_dimensions.dart';
import '../controllers/trips_controller.dart';


class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String?;
    final controller = Get.find<TripsController>();
    final trip = controller.trips.firstWhereOrNull((t) => t.id == id);
    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trajet')),
        body: const Center(child: Text('Trajet introuvable')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Détail du trajet')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Départ : ${trip.departureAgency ?? ''}'),
            Text('Arrivée : ${trip.arrivalAgency ?? ''}'),
            Text('Véhicule : ${trip.vehiclePlate ?? ''}'),
            Text('Chauffeur : ${trip.driverName ?? ''}'),
            Text('Départ prévu : ${trip.plannedDepartureAt ?? ''}'),
            Text('Arrivée prévue : ${trip.plannedArrivalAt ?? ''}'),
            Text('Statut : ${trip.status}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.tripEdit, arguments: trip.id),
              child: const Text('Modifier'),
            ),
          ],
        ),
      ),
    );
  }
}