import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/session/session_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../presentation/splash_controller.dart';

/// Binding de l'écran de démarrage.
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(
        secureStorage: Get.find<SecureStorageService>(),
        localStorage: Get.find<LocalStorageService>(),
        dioClient: Get.find<DioClient>(),
        sessionService: Get.isRegistered<SessionService>() ? Get.find<SessionService>() : null,
      ),
    );
  }
}