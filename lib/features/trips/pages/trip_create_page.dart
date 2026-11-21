import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../controllers/trips_controller.dart';

class TripCreatePage extends StatefulWidget {
  const TripCreatePage({super.key});

  @override
  State<TripCreatePage> createState() => _TripCreatePageState();
}

class _TripCreatePageState extends State<TripCreatePage> {
  final _formKey = GlobalKey<FormState>();
  String? _departureAgencyId;
  String? _arrivalAgencyId;
  String? _vehicleId;
  String? _driverId;
  final _departureController = TextEditingController();
  final _arrivalController = TextEditingController();

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  Future<void> _submit(TripsController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_departureAgencyId == null || _arrivalAgencyId == null || _vehicleId == null) return;
    final ok = await controller.create(<String, dynamic>{
      'departureAgencyId': _departureAgencyId,
      'arrivalAgencyId': _arrivalAgencyId,
      'vehicleId': _vehicleId,
      if (_driverId != null) 'driverId': _driverId,
      'plannedDepartureAt': _departureController.text.trim(),
      'plannedArrivalAt': _arrivalController.text.trim(),
    });
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TripsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau trajet')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _departureAgencyId,
                items: controller.agencies.map((a) => DropdownMenuItem(value: a['id'] as String, child: Text(a['name'] as String? ?? ''))).toList(),
                onChanged: (v) => setState(() => _departureAgencyId = v),
                decoration: const InputDecoration(labelText: 'Agence de départ'),
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              DropdownButtonFormField<String>(
                initialValue: _arrivalAgencyId,
                items: controller.agencies.map((a) => DropdownMenuItem(value: a['id'] as String, child: Text(a['name'] as String? ?? ''))).toList(),
                onChanged: (v) => setState(() => _arrivalAgencyId = v),
                decoration: const InputDecoration(labelText: 'Agence d’arrivée'),
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              DropdownButtonFormField<String>(
                initialValue: _vehicleId,
                items: controller.vehicles.map((v) => DropdownMenuItem(value: v['id'] as String, child: Text(v['plate'] as String? ?? ''))).toList(),
                onChanged: (v) => setState(() => _vehicleId = v),
                decoration: const InputDecoration(labelText: 'Véhicule'),
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _departureController,
                decoration: const InputDecoration(labelText: 'Départ prévu (ISO)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _arrivalController,
                decoration: const InputDecoration(labelText: 'Arrivée prévue (ISO)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: AppDimensions.lg),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () => _submit(controller),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Créer'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}