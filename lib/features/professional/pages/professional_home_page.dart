import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/controllers/auth_controller.dart';

class ProfessionalHomePage extends StatelessWidget {
  const ProfessionalHomePage({
    super.key,
    required this.title,
    this.subtitle = 'Espace professionnel',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.logout();
              Get.offAllNamed(AppRoutes.login);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Obx(() {
            final user = auth.user.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headline),
                const SizedBox(height: AppDimensions.xs),
                Text(subtitle, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppDimensions.md),
                Text('Utilisateur : ${user?.fullName ?? ''}', style: AppTextStyles.body),
                Text('Rôle : ${auth.primaryRole}', style: AppTextStyles.bodySmall),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await auth.logout();
                      Get.offAllNamed(AppRoutes.login);
                    },
                    child: const Text('Se déconnecter'),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}