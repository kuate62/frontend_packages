import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/directory/controllers/companies_controller.dart';

import '../controllers/shipment_request_controller.dart';

class ShipmentRequestPage extends GetView<ShipmentRequestController> {
  const ShipmentRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final companies = Get.find<CompaniesController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Envoyer un colis')),
      body: Obx(() {
        switch (controller.step.value) {
          case 0:
            return _CompanyStep(controller: controller, companies: companies);
          case 1:
            return _PickupStep(controller: controller);
          case 2:
            return _DeliveryStep(controller: controller);
          case 3:
            return _RecipientStep(controller: controller);
          case 4:
            return _ParcelStep(controller: controller);
          case 5:
            return _SummaryStep(controller: controller);
          default:
            return _ConfirmationStep(controller: controller);
        }
      }),
    );
  }
}

class _CompanyStep extends StatelessWidget {
  const _CompanyStep({required this.controller, required this.companies});

  final ShipmentRequestController controller;
  final CompaniesController companies;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choisir l’entreprise', style: AppTextStyles.headline),
          const SizedBox(height: AppDimensions.sm),
          Expanded(
            child: Obx(() {
              if (companies.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                itemCount: companies.companies.length,
                itemBuilder: (context, index) {
                  final company = companies.companies[index];
                  return Obx(() {
                    final selected = controller.tenantId.value == company.id;
                    return Card(
                      child: ListTile(
                        title: Text(company.name),
                        subtitle: Text(company.city ?? ''),
                        trailing: selected ? const Icon(Icons.check, color: AppColors.primary) : null,
                        onTap: () {
                          controller.tenantId.value = company.id;
                          controller.tenantName.value = company.name;
                        },
                      ),
                    );
                  });
                },
              );
            }),
          ),
          Obx(() {
            return ElevatedButton(
              onPressed: controller.tenantId.value == null ? null : controller.next,
              child: const Text('Continuer'),
            );
          }),
        ],
      ),
    );
  }
}

class _PickupStep extends StatelessWidget {
  const _PickupStep({required this.controller});

  final ShipmentRequestController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        children: [
          Text('Lieu d’enlèvement', style: AppTextStyles.headline),
          const SizedBox(height: AppDimensions.sm),
          TextField(controller: controller.pickupCityController, decoration: const InputDecoration(labelText: 'Ville')),
          const SizedBox(height: AppDimensions.sm),
          TextField(controller: controller.pickupAddressController, decoration: const InputDecoration(labelText: 'Adresse')),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: controller.back, child: const Text('Retour')),
              const Spacer(),
              ElevatedButton(onPressed: controller.next, child: const Text('Continuer')),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryStep extends StatelessWidget {
  const _DeliveryStep({required this.controller});

  final ShipmentRequestController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        children: [
          Text('Adresse de livraison', style: AppTextStyles.headline),
          const SizedBox(height: AppDimensions.sm),
          TextField(controller: controller.deliveryCityController, decoration: const InputDecoration(labelText: 'Ville')),
          const SizedBox(height: AppDimensions.sm),
          TextField(controller: controller.deliveryAddressController, decoration: const InputDecoration(labelText: 'Adresse')),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: controller.back, child: const Text('Retour')),
              const Spacer(),
              ElevatedButton(onPressed: controller.next, child: const Text('Continuer')),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipientStep extends StatelessWidget {
  const _RecipientStep({required this.controller});

  final ShipmentRequestController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        children: [
          Text('Destinataire', style: AppTextStyles.headline),
          const SizedBox(height: AppDimensions.sm),
          TextField(controller: controller.recipientFirstNameController, decoration: const InputDecoration(labelText: 'Prénom')),
          const SizedBox(height: AppDimensions.sm),
          TextField(controller: controller.recipientLastNameController, decoration: const InputDecoration(labelText: 'Nom')),
          const SizedBox(height: AppDimensions.sm),
          TextField(controller: controller.recipientPhoneController, decoration: const InputDecoration(labelText: 'Téléphone')),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: controller.back, child: const Text('Retour')),
              const Spacer(),
              ElevatedButton(onPressed: controller.next, child: const Text('Continuer')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParcelStep extends StatelessWidget {
  const _ParcelStep({required this.controller});

  final ShipmentRequestController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        children: [
          Text('Informations du colis', style: AppTextStyles.headline),
          const SizedBox(height: AppDimensions.sm),
          TextField(controller: controller.descriptionController, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: AppDimensions.sm),
          TextField(controller: controller.weightController, decoration: const InputDecoration(labelText: 'Poids (kg)')),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: controller.back, child: const Text('Retour')),
              const Spacer(),
              ElevatedButton(onPressed: controller.next, child: const Text('Continuer')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({required this.controller});

  final ShipmentRequestController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Récapitulatif', style: AppTextStyles.headline),
          const SizedBox(height: AppDimensions.sm),
          Text('Entreprise : ${controller.tenantName.value ?? ''}'),
          Text('Enlèvement : ${controller.pickupCityController.text}'),
          Text('Livraison : ${controller.deliveryCityController.text}'),
          Text('Destinataire : ${controller.recipientFirstNameController.text} ${controller.recipientLastNameController.text}'),
          Text('Colis : ${controller.descriptionController.text}'),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: controller.back, child: const Text('Retour')),
              const Spacer(),
              Obx(() {
                return ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : () async {
                    final ok = await controller.submit();
                    if (ok) controller.next();
                  },
                  child: controller.isSubmitting.value
                      ? const CircularProgressIndicator()
                      : const Text('Soumettre'),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfirmationStep extends StatelessWidget {
  const _ConfirmationStep({required this.controller});

  final ShipmentRequestController controller;

  @override
  Widget build(BuildContext context) {
    final request = controller.createdRequest.value;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 64),
            const SizedBox(height: AppDimensions.md),
            Text('Demande créée', style: AppTextStyles.headline),
            const SizedBox(height: AppDimensions.sm),
            Text('Référence : ${request?.id ?? ''}', style: AppTextStyles.body),
            const SizedBox(height: AppDimensions.xs),
            Text('Statut : ${request?.status ?? ''}', style: AppTextStyles.bodySmall),
            const SizedBox(height: AppDimensions.lg),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}