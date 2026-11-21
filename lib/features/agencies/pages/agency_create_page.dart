import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../controllers/agencies_controller.dart';

class AgencyCreatePage extends StatefulWidget {
  const AgencyCreatePage({super.key});

  @override
  State<AgencyCreatePage> createState() => _AgencyCreatePageState();
}

class _AgencyCreatePageState extends State<AgencyCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit(AgenciesController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await controller.create(<String, dynamic>{
      'code': _codeController.text.trim(),
      'name': _nameController.text.trim(),
      'city': _cityController.text.trim(),
      'address': _addressController.text.trim(),
      'phone': _phoneController.text.trim(),
    });
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgenciesController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle agence')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Code'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Code requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'Ville')),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Adresse')),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Téléphone')),
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