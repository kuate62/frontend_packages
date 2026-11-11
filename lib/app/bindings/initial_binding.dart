import 'package:get/get.dart';

import '../../core/config/app_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../data/storage/flutter_secure_key_value_store.dart';

/// Dépendances disponibles dès le démarrage.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AppConfig>(AppConfig.fromEnvironment(), permanent: true);
    Get.put<SecureStorageService>(
      SecureStorageService(FlutterSecureKeyValueStore()),
      permanent: true,
    );
    Get.put<LocalStorageService>(LocalStorageService(), permanent: true);
    Get.put<DioClient>(
      DioClient(
        config: Get.find<AppConfig>(),
        secureStorage: Get.find<SecureStorageService>(),
      ),
      permanent: true,
    );
  }
}
