import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../../../features/agencies/controllers/agencies_controller.dart';
import '../../../features/agencies/repositories/agencies_repository.dart';
import '../../../features/customers/controllers/customers_controller.dart';
import '../../../features/customers/repositories/customers_repository.dart';
import '../controllers/parcels_controller.dart';
import '../repositories/parcels_repository.dart';

class ParcelCreateBinding extends Bindings {
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
    Get.lazyPut<AgenciesRepository>(
      () => AgenciesRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<AgenciesController>(
      () => AgenciesController(Get.find<AgenciesRepository>()),
      fenix: true,
    );
    Get.lazyPut<ParcelsRepository>(
      () => ParcelsRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<ParcelsController>(
      () => ParcelsController(Get.find<ParcelsRepository>()),
      fenix: true,
    );
  }
}