import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/session/session_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../controllers/auth_controller.dart';
import '../repositories/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<AuthController>(
      () => AuthController(
        repository: Get.find<AuthRepository>(),
        secureStorage: Get.find<SecureStorageService>(),
        sessionService: Get.isRegistered<SessionService>() ? Get.find<SessionService>() : null,
      ),
      fenix: true,
    );
  }
}