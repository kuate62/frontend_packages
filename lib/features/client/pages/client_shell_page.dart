import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/client_shell_controller.dart';
import 'client_agencies_page.dart';
import 'client_home_page.dart';
import 'client_parcels_page.dart';
import 'client_profile_page.dart';

class ClientShellPage extends GetView<ClientShellController> {
  const ClientShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const <Widget>[
      ClientHomePage(),
      ClientParcelsPage(),
      ClientAgenciesPage(),
      ClientProfilePage(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value.clamp(0, pages.length - 1),
            children: pages,
          )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Get.toNamed(AppRoutes.shipmentRequest),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Obx(() {
          final index = controller.currentIndex.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Accueil',
                selected: index == 0,
                onTap: () => controller.changeTab(0),
              ),
              _NavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Mes colis',
                selected: index == 1,
                onTap: () => controller.changeTab(1),
              ),
              const SizedBox(width: 48),
              _NavItem(
                icon: Icons.location_on_outlined,
                label: 'Agences',
                selected: index == 2,
                onTap: () => controller.changeTab(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Profil',
                selected: index == 3,
                onTap: () => controller.changeTab(3),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            Text(label, style: AppTextStyles.caption.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}