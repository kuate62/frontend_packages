import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../controllers/company_dashboard_controller.dart';
import '../repositories/company_dashboard_repository.dart';

class CompanyDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyDashboardRepository>(
      () => CompanyDashboardRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<CompanyDashboardController>(
      () => CompanyDashboardController(Get.find<CompanyDashboardRepository>()),
      fenix: true,
    );
  }
}
