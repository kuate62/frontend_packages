import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/controllers/auth_controller.dart';

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Obx(() {
          final user = auth.user.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.fullName ?? '', style: AppTextStyles.headline),
              const SizedBox(height: AppDimensions.xs),
              Text(user?.email ?? '', style: AppTextStyles.body),
              if (user?.phone != null) ...[
                const SizedBox(height: AppDimensions.xs),
                Text(user!.phone!, style: AppTextStyles.bodySmall),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                  ),
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
    );
  }
}