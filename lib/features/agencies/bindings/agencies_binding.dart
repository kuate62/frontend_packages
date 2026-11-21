import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../controllers/agencies_controller.dart';
import '../repositories/agencies_repository.dart';

class AgenciesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgenciesRepository>(
      () => AgenciesRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<AgenciesController>(
      () => AgenciesController(Get.find<AgenciesRepository>()),
      fenix: true,
    );
  }
}