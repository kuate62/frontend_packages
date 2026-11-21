import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../core/theme/app_dimensions.dart';
import '../controllers/trips_controller.dart';

class TripEditPage extends StatefulWidget {
  const TripEditPage({super.key});

  @override
  State<TripEditPage> createState() => _TripEditPageState();
}

class _TripEditPageState extends State<TripEditPage> {
  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();
  String? _vehicleId;
  String? _driverId;

  @override
  void initState() {
    super.initState();
    final id = Get.arguments as String?;
    final controller = Get.find<TripsController>();
    final trip = controller.trips.firstWhereOrNull((t) => t.id == id);
    if (trip != null) {
      _departureController.text = trip.plannedDepartureAt ?? '';
      _arrivalController.text = trip.plannedArrivalAt ?? '';
    }
  }

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  Future<void> _submit(TripsController controller) async {
    final id = Get.arguments as String?;
    if (id == null) return;
    final payload = <String, dynamic>{};
    if (_departureController.text.trim().isNotEmpty) payload['plannedDepartureAt'] = _departureController.text.trim();
    if (_arrivalController.text.trim().isNotEmpty) payload['plannedArrivalAt'] = _arrivalController.text.trim();
    if (_vehicleId != null) payload['vehicleId'] = _vehicleId;
    if (_driverId != null) payload['driverId'] = _driverId;
    final ok = await controller.patch(id, payload);
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le trajet')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _vehicleId,
              items: controller.vehicles.map((v) => DropdownMenuItem(value: v['id'] as String, child: Text(v['plate'] as String? ?? ''))).toList(),
              onChanged: (v) => setState(() => _vehicleId = v),
              decoration: const InputDecoration(labelText: 'Véhicule'),
            ),
            const SizedBox(height: AppDimensions.sm),
            DropdownButtonFormField<String>(
              initialValue: _driverId,
              items: controller.drivers.map((d) => DropdownMenuItem(value: d['id'] as String, child: Text('${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'))).toList(),
              onChanged: (v) => setState(() => _driverId = v),
              decoration: const InputDecoration(labelText: 'Chauffeur'),
            ),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(controller: _departureController, decoration: const InputDecoration(labelText: 'Départ prévu (ISO)')),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(controller: _arrivalController, decoration: const InputDecoration(labelText: 'Arrivée prévue (ISO)')),
            const SizedBox(height: AppDimensions.lg),
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => _submit(controller),
                  child: controller.isLoading.value ? const CircularProgressIndicator() : const Text('Enregistrer'),
                )),
          ],
        ),
      ),
    );
  }
}