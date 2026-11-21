import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../../parcels/repositories/parcels_repository.dart';
import '../controllers/reception_controller.dart';

class ReceptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParcelsRepository>(
      () => ParcelsRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<ReceptionController>(
      () => ReceptionController(Get.find<ParcelsRepository>()),
      fenix: true,
    );
  }
}