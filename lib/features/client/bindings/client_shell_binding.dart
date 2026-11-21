import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../../../features/directory/controllers/agencies_controller.dart';
import '../../../features/directory/controllers/companies_controller.dart';
import '../../../features/directory/repositories/directory_repository.dart';
import '../../../features/parcels/controllers/my_parcels_controller.dart';
import '../../../features/parcels/repositories/my_parcels_repository.dart';
import '../controllers/client_shell_controller.dart';

class ClientShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientShellController>(() => ClientShellController(), fenix: true);

    if (!Get.isRegistered<DirectoryRepository>()) {
      Get.lazyPut<DirectoryRepository>(
        () => DirectoryRepository(Get.find<DioClient>().dio),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AgenciesController>()) {
      Get.lazyPut<AgenciesController>(
        () => AgenciesController(Get.find<DirectoryRepository>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CompaniesController>()) {
      Get.lazyPut<CompaniesController>(
        () => CompaniesController(Get.find<DirectoryRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<MyParcelsRepository>()) {
      Get.lazyPut<MyParcelsRepository>(
        () => MyParcelsRepository(Get.find<DioClient>().dio),
        fenix: true,
      );
    }
    if (!Get.isRegistered<MyParcelsController>()) {
      Get.lazyPut<MyParcelsController>(
        () => MyParcelsController(Get.find<MyParcelsRepository>()),
        fenix: true,
      );
    }
  }
}