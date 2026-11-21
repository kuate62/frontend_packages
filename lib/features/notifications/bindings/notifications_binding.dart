import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../controllers/notifications_controller.dart';
import '../repositories/notifications_repository.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsRepository>(
      () => NotificationsRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(Get.find<NotificationsRepository>()),
      fenix: true,
    );
  }
}