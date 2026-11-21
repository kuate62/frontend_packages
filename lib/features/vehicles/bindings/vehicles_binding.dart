import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../controllers/vehicles_controller.dart';
import '../repositories/vehicles_repository.dart';

class VehiclesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VehiclesRepository>(
      () => VehiclesRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<VehiclesController>(
      () => VehiclesController(Get.find<VehiclesRepository>()),
      fenix: true,
    );
  }
}