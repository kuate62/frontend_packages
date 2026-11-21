import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../controllers/my_parcels_controller.dart';
import '../repositories/my_parcels_repository.dart';

class MyParcelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyParcelsRepository>(
      () => MyParcelsRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<MyParcelsController>(
      () => MyParcelsController(Get.find<MyParcelsRepository>()),
      fenix: true,
    );
  }
}