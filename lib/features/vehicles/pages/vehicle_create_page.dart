import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../controllers/vehicles_controller.dart';

class VehicleCreatePage extends StatefulWidget {
  const VehicleCreatePage({super.key});

  @override
  State<VehicleCreatePage> createState() => _VehicleCreatePageState();
}

class _VehicleCreatePageState extends State<VehicleCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'BUS';

  @override
  void dispose() {
    _plateController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit(VehiclesController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await controller.create(<String, dynamic>{
      'plate': _plateController.text.trim(),
      'type': _type,
      'capacityKg': double.tryParse(_capacityController.text.trim()) ?? 0,
      'description': _descriptionController.text.trim(),
    });
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VehiclesController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau véhicule')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(labelText: 'Immatriculation'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Immatriculation requise' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              DropdownButtonFormField<String>(
                initialValue: _type,
                items: const [
                  DropdownMenuItem(value: 'BUS', child: Text('Bus')),
                  DropdownMenuItem(value: 'COACH', child: Text('Coach')),
                  DropdownMenuItem(value: 'MINIBUS', child: Text('Minibus')),
                  DropdownMenuItem(value: 'VAN', child: Text('Van')),
                  DropdownMenuItem(value: 'TRUCK', child: Text('Camion')),
                  DropdownMenuItem(value: 'OTHER', child: Text('Autre')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'BUS'),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacité (kg)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null || value <= 0) return 'Capacité invalide';
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
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