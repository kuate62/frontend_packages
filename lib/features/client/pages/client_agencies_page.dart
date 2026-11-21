import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../directory/controllers/agencies_controller.dart';

class ClientAgenciesPage extends GetView<AgenciesController> {
  const ClientAgenciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agences')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher une agence',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => controller.load(search: value),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value != null) {
                return Center(child: Text(controller.errorMessage.value!));
              }
              if (controller.agencies.isEmpty) {
                return const Center(child: Text('Aucune agence disponible'));
              }
              return ListView.builder(
                itemCount: controller.agencies.length,
                itemBuilder: (context, index) {
                  final agency = controller.agencies[index];
                  return Card(
                    margin: const EdgeInsets.all(AppDimensions.sm),
                    child: ListTile(
                      title: Text(agency.name),
                      subtitle: Text('${agency.tenantName ?? ''} - ${agency.city ?? agency.address ?? ''}'),
                      trailing: agency.phone == null ? null : Text(agency.phone!),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}