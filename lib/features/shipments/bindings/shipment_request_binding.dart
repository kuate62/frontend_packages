import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../../../features/directory/controllers/companies_controller.dart';
import '../../../features/directory/repositories/directory_repository.dart';
import '../controllers/shipment_request_controller.dart';
import '../repositories/shipment_requests_repository.dart';

class ShipmentRequestBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DirectoryRepository>()) {
      Get.lazyPut<DirectoryRepository>(
        () => DirectoryRepository(Get.find<DioClient>().dio),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CompaniesController>()) {
      Get.lazyPut<CompaniesController>(
        () => CompaniesController(Get.find<DirectoryRepository>()),
        fenix: true,
      );
    }
    Get.lazyPut<ShipmentRequestsRepository>(
      () => ShipmentRequestsRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<ShipmentRequestController>(
      () => ShipmentRequestController(Get.find<ShipmentRequestsRepository>()),
      fenix: true,
    );
  }
}