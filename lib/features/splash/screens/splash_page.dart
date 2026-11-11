import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_error_view.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/splash_controller.dart';

/// Écran technique d'ouverture. Aucun parcours métier.
class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final environment = Get.find<AppConfig>().environment.label;
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          return switch (controller.status.value) {
            SplashStatus.loading => const AppLoadingIndicator(
              message: 'Préparation d’ExpressIO',
            ),
            SplashStatus.error => AppErrorView(
              message:
                  controller.errorMessage.value ??
                  'Le stockage sécurisé est indisponible.',
              onRetry: controller.prepare,
            ),
            SplashStatus.ready => const _ReadySplash(),
          };
        }),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.md),
          child: Text(
            environment,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}

class _ReadySplash extends StatelessWidget {
  const _ReadySplash();

  @override
  Widget build(BuildContext context) {
    final isDev =
        Get.find<AppConfig>().environment == AppEnvironment.development;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 48,
              color: AppColors.seed,
            ),
            const SizedBox(height: AppDimensions.md),
            const Text('ExpressIO', style: AppTextStyles.title),
            const SizedBox(height: AppDimensions.xs),
            const Text(
              'Gestion et suivi de colis',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            if (isDev) ...[
              const SizedBox(height: AppDimensions.lg),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.designSystemPreview),
                child: const Text('Design System (dev)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
