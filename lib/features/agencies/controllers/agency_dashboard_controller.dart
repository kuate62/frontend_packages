import 'package:get/get.dart';

import '../models/agency_dashboard_data.dart';
import '../repositories/agency_dashboard_repository.dart';

/// Contrôleur GetX pour le tableau de bord opérationnel du Responsable d'Agence (V1-12).
class AgencyDashboardController extends GetxController {
  AgencyDashboardController(this._repository);

  final AgencyDashboardRepository _repository;

  final dashboardData = Rxn<AgencyDashboardData>();
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
      errorMessage.value = 'Impossible de charger les statistiques de l\'agence.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => loadDashboard();
}
