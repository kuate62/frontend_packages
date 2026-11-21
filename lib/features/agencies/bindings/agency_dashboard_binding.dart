import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../controllers/agency_dashboard_controller.dart';
import '../repositories/agency_dashboard_repository.dart';

/// Injection des dépendances pour le tableau de bord de l'AGENCY_MANAGER.
class AgencyDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgencyDashboardRepository>(
      () => AgencyDashboardRepository(Get.find<Dio>()),
    );
    Get.lazyPut<AgencyDashboardController>(
      () => AgencyDashboardController(Get.find<AgencyDashboardRepository>()),
    );
  }
}
