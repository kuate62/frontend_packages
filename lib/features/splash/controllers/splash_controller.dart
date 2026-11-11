import 'package:get/get.dart';

import '../../../core/storage/secure_storage_service.dart';

enum SplashStatus { loading, ready, error }

/// Vérifie que le stockage de session est accessible au démarrage.
class SplashController extends GetxController {
  SplashController(this._secureStorage);

  final SecureStorageService _secureStorage;

  final status = SplashStatus.loading.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    prepare();
  }

  Future<void> prepare() async {
    status.value = SplashStatus.loading;
    errorMessage.value = null;
    try {
      await _secureStorage.readAccessToken();
      status.value = SplashStatus.ready;
    } catch (_) {
      errorMessage.value = 'Le stockage sécurisé est indisponible.';
      status.value = SplashStatus.error;
    }
  }
}
