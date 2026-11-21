import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../../trips/repositories/trips_repository.dart';
import '../controllers/driver_controller.dart';

class DriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripsRepository>(
      () => TripsRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<DriverController>(
      () => DriverController(Get.find<TripsRepository>()),
      fenix: true,
    );
  }
}