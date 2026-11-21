import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../controllers/companies_controller.dart';
import '../repositories/directory_repository.dart';

class CompaniesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DirectoryRepository>(
      () => DirectoryRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<CompaniesController>(
      () => CompaniesController(Get.find<DirectoryRepository>()),
      fenix: true,
    );
  }
}