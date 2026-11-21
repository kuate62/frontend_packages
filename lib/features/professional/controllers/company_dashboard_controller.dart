import 'package:get/get.dart';

import '../models/company_dashboard_data.dart';
import '../repositories/company_dashboard_repository.dart';

/// Contrôleur GetX pour le tableau de bord Administrateur d'Entreprise.
class CompanyDashboardController extends GetxController {
  CompanyDashboardController(this._repository);

  final CompanyDashboardRepository _repository;

  final dashboardData = Rxn<CompanyDashboardData>();
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
      final data = await _repository.getOverview();
      dashboardData.value = data;
    } catch (_) {
      errorMessage.value = 'Impossible de charger les statistiques de l\'entreprise.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => loadDashboard();
}
