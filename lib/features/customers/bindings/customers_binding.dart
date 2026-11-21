import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../controllers/customers_controller.dart';
import '../repositories/customers_repository.dart';

class CustomersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomersRepository>(
      () => CustomersRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<CustomersController>(
      () => CustomersController(Get.find<CustomersRepository>()),
      fenix: true,
    );
  }
}