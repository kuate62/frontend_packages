import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../controllers/super_admin_controller.dart';
import '../controllers/super_admin_dashboard_controller.dart';
import '../controllers/super_admin_users_controller.dart';
import '../repositories/super_admin_dashboard_repository.dart';
import '../repositories/tenants_repository.dart';
import '../repositories/users_repository.dart';

class SuperAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TenantsRepository>(
      () => TenantsRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<UsersRepository>(
      () => UsersRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<SuperAdminDashboardRepository>(
      () => SuperAdminDashboardRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<SuperAdminController>(
      () => SuperAdminController(Get.find<TenantsRepository>()),
      fenix: true,
    );
    Get.lazyPut<SuperAdminUsersController>(
      () => SuperAdminUsersController(Get.find<UsersRepository>()),
      fenix: true,
    );
    Get.lazyPut<SuperAdminDashboardController>(
      () => SuperAdminDashboardController(Get.find<SuperAdminDashboardRepository>()),
      fenix: true,
    );
  }
}