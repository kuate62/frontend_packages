import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../controllers/trips_controller.dart';
import '../repositories/trips_repository.dart';

class TripsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripsRepository>(
      () => TripsRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<TripsController>(
      () => TripsController(Get.find<TripsRepository>()),
      fenix: true,
    );
  }
}