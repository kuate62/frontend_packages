import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../controllers/client_shell_controller.dart';
import '../../../features/parcels/controllers/my_parcels_controller.dart';

import '../../../shared/widgets/app_text_field.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final _trackingController = TextEditingController();

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _track() async {
    final code = _trackingController.text.trim();
    if (code.isEmpty) {
      Get.snackbar('Suivi', 'Saisissez un code de suivi.');
      return;
    }
    try {
      final dio = Get.find<DioClient>().dio;
      final response = await dio.get<Map<String, dynamic>>('/public/tracking/$code');
      final data = response.data?['data'] as Map<String, dynamic>?;
      Get.snackbar(
        'Suivi',
        data?['statusLabel'] as String? ?? 'Colis trouvé.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Suivi',
        'Colis introuvable ou erreur réseau.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final parcelsController = Get.find<MyParcelsController>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: parcelsController.load,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.md),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      final name = auth.user.value?.firstName ?? '';
                      return Text(
                        name.isEmpty ? 'Bonjour' : 'Bonjour, $name',
                        style: AppTextStyles.headline,
                      );
                    }),
                  ),
                  IconButton(
                    onPressed: () => Get.toNamed(AppRoutes.notifications),
                    icon: const Icon(Icons.notifications_none),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.person_outline),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Vos colis, toujours en mouvement.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.lg),
              Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppDimensions.radius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Envoyer un colis',
                      style: AppTextStyles.title.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      'Faites expédier votre colis vers sa destination en quelques étapes.',
                      style: AppTextStyles.body.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.secondary,
                      ),
                      onPressed: () => Get.toNamed(AppRoutes.shipmentRequest),
                      child: const Text('Envoyer un colis'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              Text('Où est votre colis ?', style: AppTextStyles.subtitle),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'Retrouvez les dernières informations sur votre expédition.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.sm),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Code de suivi',
                      controller: _trackingController,
                      prefixIcon: Icons.search,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  SizedBox(
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _track,
                      child: const Text('Suivre'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('En cours', style: AppTextStyles.subtitle),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.claims),
                    child: const Text('Réclamations'),
                  ),
                ],
              ),
              Obx(() {
                if (parcelsController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (parcelsController.errorMessage.value != null) {
                  return Text(parcelsController.errorMessage.value!);
                }
                final items = parcelsController.parcels.take(3).toList();
                if (items.isEmpty) {
                  return const Text('Aucun envoi pour le moment');
                }
                return Column(
                  children: items.map((parcel) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                      child: ListTile(
                        title: Text(parcel.trackingCode),
                        subtitle: Text(
                          '${parcel.departureAgency?.city ?? ''} → ${parcel.arrivalAgency?.city ?? ''}',
                        ),
                        trailing: Text(parcel.statusLabel),
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: AppDimensions.lg),
              Text('Accès rapides', style: AppTextStyles.subtitle),
              const SizedBox(height: AppDimensions.sm),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.inventory_2_outlined,
                      label: 'Mes colis',
                      onTap: () => Get.find<ClientShellController>().changeTab(1),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.location_on_outlined,
                      label: 'Agences',
                      onTap: () => Get.find<ClientShellController>().changeTab(2),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.help_outline,
                      label: 'Assistance',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: AppDimensions.xs),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}