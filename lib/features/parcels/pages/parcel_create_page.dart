import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../agencies/controllers/agencies_controller.dart';
import '../../customers/controllers/customers_controller.dart';
import '../../customers/models/customer.dart';
import '../controllers/parcels_controller.dart';
import '../repositories/parcels_repository.dart';

class ParcelCreatePage extends StatefulWidget {
  const ParcelCreatePage({super.key});

  @override
  State<ParcelCreatePage> createState() => _ParcelCreatePageState();
}

class _ParcelCreatePageState extends State<ParcelCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _senderPhoneController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();

  Customer? _sender;
  String? _departureAgencyId;
  String? _arrivalAgencyId;

  @override
  void dispose() {
    _senderPhoneController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _searchSender(CustomersController controller) async {
    await controller.search(_senderPhoneController.text);
    if (controller.results.isNotEmpty) {
      setState(() => _sender = controller.results.first);
    }
  }

  Future<void> _submit(ParcelsController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_sender == null || _departureAgencyId == null || _arrivalAgencyId == null) return;
    try {
      final parts = _recipientNameController.text.trim().split(' ');
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : firstName;
      final recipient = await Get.find<CustomersController>().create(<String, dynamic>{
        'lastName': lastName,
        'phone': _recipientPhoneController.text.trim(),
        'firstName': firstName,
      });
      if (recipient == null) return;
      final dio = Get.find<ParcelsRepository>().dio;
      final response = await dio.post<Map<String, dynamic>>('/parcels', data: <String, dynamic>{
        'departureAgencyId': _departureAgencyId,
        'arrivalAgencyId': _arrivalAgencyId,
        'senderId': _sender!.id,
        'recipientId': recipient.id,
        'description': _descriptionController.text.trim(),
        'weightKg': double.tryParse(_weightController.text.trim()) ?? 0,
      });
      final data = response.data?['data'] as Map<String, dynamic>?;
      final parcel = data?['parcel'] as Map<String, dynamic>?;
      final pricing = data?['pricing'] as Map<String, dynamic>?;
      if (parcel != null) {
        final amount = pricing?['total'];
        final currency = pricing?['currency'] ?? 'XAF';
        Get.snackbar(
          'Succès',
          'Colis créé : ${parcel['trackingCode']} - Montant : $amount $currency',
        );
        Get.back();
      }
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible de créer le colis.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = Get.find<CustomersController>();
    final agencies = Get.find<AgenciesController>();
    final parcels = Get.find<ParcelsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau colis')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _senderPhoneController,
                      decoration: const InputDecoration(labelText: 'Téléphone expéditeur'),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _searchSender(customers),
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
              if (_sender != null) Text('Expéditeur : ${_sender!.fullName}'),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _recipientNameController,
                decoration: const InputDecoration(labelText: 'Nom destinataire'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _recipientPhoneController,
                decoration: const InputDecoration(labelText: 'Téléphone destinataire'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              DropdownButtonFormField<String>(
                initialValue: _departureAgencyId,
                items: agencies.agencies.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                onChanged: (v) => setState(() => _departureAgencyId = v),
                decoration: const InputDecoration(labelText: 'Agence de départ'),
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              DropdownButtonFormField<String>(
                initialValue: _arrivalAgencyId,
                items: agencies.agencies.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                onChanged: (v) => setState(() => _arrivalAgencyId = v),
                decoration: const InputDecoration(labelText: 'Agence d’arrivée'),
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Poids (kg)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null || value <= 0) return 'Poids invalide';
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.lg),
              ElevatedButton(
                onPressed: () => _submit(parcels),
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}