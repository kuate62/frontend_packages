import 'package:get/get.dart';

import '../models/super_admin_dashboard_data.dart';
import '../repositories/super_admin_dashboard_repository.dart';

/// Contrôleur GetX pour le Dashboard Super Admin.
class SuperAdminDashboardController extends GetxController {
  SuperAdminDashboardController(this._repository);

  final SuperAdminDashboardRepository _repository;

  final dashboardData = Rxn<SuperAdminDashboardData>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final data = await _repository.getDashboard();
      dashboardData.value = data;
    } catch (_) {
      errorMessage.value = 'Impossible de charger les statistiques globales.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => loadDashboard();
}
