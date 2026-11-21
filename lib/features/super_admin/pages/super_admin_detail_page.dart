import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_confirm_dialog.dart';
import '../controllers/super_admin_controller.dart';
import '../models/tenant.dart';
import '../repositories/tenants_repository.dart';

class SuperAdminDetailPage extends StatefulWidget {
  const SuperAdminDetailPage({super.key, this.tenantId});

  final String? tenantId;

  @override
  State<SuperAdminDetailPage> createState() => _SuperAdminDetailPageState();
}

class _SuperAdminDetailPageState extends State<SuperAdminDetailPage> {
  bool _isLoading = false;

  Future<void> _handleStatusAction(BuildContext context, Tenant tenant) async {
    final isSuspending = tenant.status == 'ACTIVE';
    final confirmed = await AppConfirmDialog.show(
      context,
      title: isSuspending ? 'Confirmer la suspension' : 'Confirmer la réactivation',
      message: isSuspending
          ? 'Êtes-vous sûr de vouloir suspendre cette entreprise ?'
          : 'Êtes-vous sûr de vouloir réactiver cette entreprise ?',
      confirmLabel: isSuspending ? 'Suspendre' : 'Réactiver',
      cancelLabel: 'Annuler',
      isDestructive: isSuspending,
    );

    if (!confirmed || !mounted) return;

    await _setStatus(tenant.id, isSuspending ? 'SUSPENDED' : 'ACTIVE');
  }

  Future<void> _setStatus(String id, String status) async {
    setState(() => _isLoading = true);
    try {
      final repo = Get.find<TenantsRepository>();
      final updated = await repo.setStatus(id, status);
      final controller = Get.find<SuperAdminController>();
      final index = controller.tenants.indexWhere((t) => t.id == id);
      if (index != -1) controller.tenants[index] = updated;
      Get.snackbar('Succès', 'Statut mis à jour');
    } catch (_) {
      Get.snackbar('Erreur', 'Opération impossible');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.tenantId ?? (Get.arguments as String?);
    final controller = Get.find<SuperAdminController>();

    return Obx(() {
      final tenant = controller.tenants.firstWhereOrNull((t) => t.id == id);
      if (tenant == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Entreprise')),
          body: const Center(child: Text('Entreprise introuvable')),
        );
      }

      final isSuspended = tenant.status == 'SUSPENDED';

      return Scaffold(
        appBar: AppBar(title: Text(tenant.name)),
        body: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Identifiant : ${tenant.id}'),
              Text('Code : ${tenant.code ?? ''}'),
              Text('Ville : ${tenant.city ?? ''}'),
              Text('Statut : ${tenant.status ?? ''}', key: const Key('tenant_status_text')),
              const Spacer(),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('toggle_status_button'),
                    onPressed: () => _handleStatusAction(context, tenant),
                    child: Text(isSuspended ? 'Réactiver' : 'Suspendre'),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
