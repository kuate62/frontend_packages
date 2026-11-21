import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../controllers/parcels_controller.dart';
import '../repositories/parcels_repository.dart';

class ParcelsBinding extends Bindings {
  @override
  void dependencies() {
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