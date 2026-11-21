import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../features/parcels/models/my_parcel.dart';
import '../../../features/parcels/repositories/my_parcels_repository.dart';
import '../controllers/claims_controller.dart';

class ClaimCreatePage extends StatefulWidget {
  const ClaimCreatePage({super.key});

  @override
  State<ClaimCreatePage> createState() => _ClaimCreatePageState();
}

class _ClaimCreatePageState extends State<ClaimCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'DELAY';

  List<MyParcel> _parcels = [];
  bool _isLoadingParcels = true;
  String? _selectedParcelId;

  @override
  void initState() {
    super.initState();
    _loadParcels();
  }

  Future<void> _loadParcels() async {
    try {
      final repo = Get.find<MyParcelsRepository>();
      final parcels = await repo.listMyParcels();
      setState(() {
        _parcels = parcels;
        _isLoadingParcels = false;
        if (parcels.isNotEmpty) _selectedParcelId = parcels.first.id;
      });
    } catch (_) {
      setState(() => _isLoadingParcels = false);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit(ClaimsController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedParcelId == null) return;
    final ok = await controller.create(<String, dynamic>{
      'parcelId': _selectedParcelId,
      'category': _category,
      'subject': _subjectController.text.trim(),
      'description': _descriptionController.text.trim(),
    });
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClaimsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle réclamation')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_isLoadingParcels)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedParcelId,
                  items: _parcels
                      .map((p) => DropdownMenuItem(value: p.id, child: Text(p.trackingCode)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedParcelId = v),
                  decoration: const InputDecoration(labelText: 'Colis'),
                  validator: (v) => v == null ? 'Requis' : null,
                ),
              const SizedBox(height: AppDimensions.sm),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: const [
                  DropdownMenuItem(value: 'DELAY', child: Text('Retard')),
                  DropdownMenuItem(value: 'LOST', child: Text('Perdu')),
                  DropdownMenuItem(value: 'DAMAGED', child: Text('Endommagé')),
                  DropdownMenuItem(value: 'DELIVERY_ISSUE', child: Text('Problème de livraison')),
                  DropdownMenuItem(value: 'PAYMENT_ISSUE', child: Text('Problème de paiement')),
                  DropdownMenuItem(value: 'OTHER', child: Text('Autre')),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'DELAY'),
                decoration: const InputDecoration(labelText: 'Catégorie'),
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Objet'),
                validator: (v) => (v == null || v.trim().length < 3) ? 'Minimum 3 caractères' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => (v == null || v.trim().length < 10) ? 'Minimum 10 caractères' : null,
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