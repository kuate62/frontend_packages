import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/agencies_controller.dart';

class AgencyDetailPage extends StatelessWidget {
  const AgencyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String?;
    final controller = Get.find<AgenciesController>();
    final agency = controller.agencies.firstWhereOrNull((a) => a.id == id);
    if (agency == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Agence')),
        body: const Center(child: Text('Agence introuvable')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(agency.name)),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code : ${agency.code}', style: AppTextStyles.body),
            Text('Ville : ${agency.city ?? ''}', style: AppTextStyles.body),
            Text('Adresse : ${agency.address ?? ''}', style: AppTextStyles.body),
            Text('Téléphone : ${agency.phone ?? ''}', style: AppTextStyles.body),
            Text('Statut : ${agency.status}', style: AppTextStyles.body),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: agency.isActive ? () => controller.deactivate(agency.id) : null,
                child: Text(agency.isActive ? 'Désactiver' : 'Désactivée'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}