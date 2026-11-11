import 'package:get/get.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../controllers/splash_controller.dart';

/// Binding de l'écran de démarrage.
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(Get.find<SecureStorageService>()),
    );
  }
}
