import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../repositories/parcels_repository.dart';
import '../../payments/repositories/payments_repository.dart';

class ParcelDetailPage extends StatefulWidget {
  const ParcelDetailPage({super.key});

  @override
  State<ParcelDetailPage> createState() => _ParcelDetailPageState();
}

class _ParcelDetailPageState extends State<ParcelDetailPage> {
  Map<String, dynamic>? _parcel;
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  bool _isPaying = false;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = Get.arguments as String?;
    if (id == null) return;
    final repo = ParcelsRepository(Get.find<ParcelsRepository>().dio);
    final parcel = await repo.get(id);
    final events = await repo.events(id);
    final payments = await repo.payments(id);
    setState(() {
      _parcel = parcel;
      _events = events;
      _payments = payments;
      _isLoading = false;
    });
  }

  Future<void> _pay() async {
    final id = _parcel?['id'] as String?;
    final amount = double.tryParse(_amountController.text.trim());
    if (id == null || amount == null) return;
    setState(() => _isPaying = true);
    try {
      final repo = PaymentsRepository(Get.find<ParcelsRepository>().dio);
      await repo.createPayment(parcelId: id, amount: amount, mode: 'CASH');
      Get.snackbar('Succès', 'Paiement enregistré');
    } catch (_) {
      Get.snackbar('Erreur', 'Paiement impossible');
    } finally {
      setState(() => _isPaying = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final parcel = _parcel;
    if (parcel == null) {
      return const Scaffold(body: Center(child: Text('Colis introuvable')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(parcel['trackingCode'] as String? ?? '')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Statut : ${parcel['status']}'),
              const SizedBox(height: AppDimensions.sm),
              Text('Poids : ${parcel['weightKg']}'),
              const SizedBox(height: AppDimensions.md),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Montant'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimensions.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPaying ? null : _pay,
                  child: _isPaying ? const CircularProgressIndicator() : const Text('Enregistrer le paiement'),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              ElevatedButton(
                onPressed: () {
                  final id = parcel['id'] as String?;
                  if (id != null) Get.toNamed(AppRoutes.parcelWaybill, arguments: id);
                },
                child: const Text('Bordereau PDF'),
              ),
              const SizedBox(height: AppDimensions.lg),
              Text('Historique', style: AppTextStyles.subtitle),
              const SizedBox(height: AppDimensions.sm),
              if (_events.isEmpty) const Text('Aucun événement'),
              ..._events.map((e) => Text('${e['eventType'] ?? e['status']} - ${e['createdAt'] ?? ''}')),
              const SizedBox(height: AppDimensions.lg),
              Text('Paiements', style: AppTextStyles.subtitle),
              const SizedBox(height: AppDimensions.sm),
              if (_payments.isEmpty) const Text('Aucun paiement'),
              ..._payments.map((p) => Text('${p['amount']} ${p['currency']} - ${p['status']}')),
            ],
          ),
        ),
      ),
    );
  }
}