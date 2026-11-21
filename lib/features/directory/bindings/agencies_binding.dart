import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../controllers/agencies_controller.dart';
import '../repositories/directory_repository.dart';

class AgenciesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DirectoryRepository>(
      () => DirectoryRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<AgenciesController>(
      () => AgenciesController(Get.find<DirectoryRepository>()),
      fenix: true,
    );
  }
}