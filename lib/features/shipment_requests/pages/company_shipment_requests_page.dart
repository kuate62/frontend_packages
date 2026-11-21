import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

import '../controllers/company_shipment_requests_controller.dart';

class CompanyShipmentRequestsPage extends GetView<CompanyShipmentRequestsController> {
  const CompanyShipmentRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demandes d’expédition')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: DropdownButtonFormField<String>(
              initialValue: controller.statusFilter.value,
              items: const [
                DropdownMenuItem(value: 'SUBMITTED', child: Text('En attente')),
                DropdownMenuItem(value: 'ACCEPTED', child: Text('Acceptées')),
                DropdownMenuItem(value: 'REJECTED', child: Text('Refusées')),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.statusFilter.value = value;
                  controller.load();
                }
              },
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
              if (controller.requests.isEmpty) {
                return const Center(child: Text('Aucune demande'));
              }
              return ListView.builder(
                itemCount: controller.requests.length,
                itemBuilder: (context, index) {
                  final request = controller.requests[index];
                  return Card(
                    margin: const EdgeInsets.all(AppDimensions.sm),
                    child: ListTile(
                      title: Text('${request.recipientFirstName} ${request.recipientLastName}'),
                      subtitle: Text('${request.pickupCity} → ${request.deliveryCity}'),
                      trailing: request.status == 'SUBMITTED'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: AppColors.success),
                                  onPressed: () => controller.accept(request.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.danger),
                                  onPressed: () => _reject(context, controller, request.id),
                                ),
                              ],
                            )
                          : Text(request.status),
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

  Future<void> _reject(BuildContext context, CompanyShipmentRequestsController controller, String id) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la demande'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Motif'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, reasonController.text), child: const Text('Refuser')),
        ],
      ),
    );
    if (reason != null && reason.trim().isNotEmpty) {
      await controller.reject(id, reason.trim());
    }
  }
}