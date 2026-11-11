import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend_packages/app/bindings/initial_binding.dart';
import 'package:frontend_packages/core/config/app_config.dart';
import 'package:frontend_packages/core/network/dio_client.dart';
import 'package:frontend_packages/core/storage/secure_storage_service.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  test('InitialBinding enregistre la configuration, le stockage et Dio', () {
    InitialBinding().dependencies();

    expect(Get.isRegistered<AppConfig>(), isTrue);
    expect(Get.isRegistered<SecureStorageService>(), isTrue);
    expect(Get.isRegistered<DioClient>(), isTrue);
    expect(Get.find<DioClient>().dio.options.baseUrl, endsWith('/api/v1/'));
  });
}
