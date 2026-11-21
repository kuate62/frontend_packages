import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../features/auth/controllers/auth_controller.dart';

class AgentHomePage extends StatelessWidget {
  const AgentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent'),
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
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.parcels),
              child: const Text('Colis'),
            ),
            const SizedBox(height: AppDimensions.sm),
            ElevatedButton(
              onPressed: () => Get.snackbar('Info', 'Création de colis non disponible : endpoint clients manquant.'),
              child: const Text('Nouveau colis'),
            ),
          ],
        ),
      ),
    );
  }
}