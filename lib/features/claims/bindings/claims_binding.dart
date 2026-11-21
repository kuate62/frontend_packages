import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../../../features/parcels/repositories/my_parcels_repository.dart';
import '../controllers/claims_controller.dart';
import '../repositories/claims_repository.dart';

class ClaimsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClaimsRepository>(
      () => ClaimsRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<ClaimsController>(
      () => ClaimsController(Get.find<ClaimsRepository>()),
      fenix: true,
    );
    if (!Get.isRegistered<MyParcelsRepository>()) {
      Get.lazyPut<MyParcelsRepository>(
        () => MyParcelsRepository(Get.find<DioClient>().dio),
        fenix: true,
      );
    }
  }
}