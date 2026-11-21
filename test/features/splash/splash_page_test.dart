import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_packages/app/expressio_app.dart';
import 'package:frontend_packages/core/config/app_config.dart';
import 'package:frontend_packages/core/network/dio_client.dart';
import 'package:frontend_packages/core/storage/local_storage_service.dart';
import 'package:frontend_packages/core/storage/secure_key_value_store.dart';
import 'package:frontend_packages/core/storage/secure_storage_service.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('la route initiale affiche le splash puis redirige', (tester) async {
    await tester.pumpWidget(ExpressioApp(initialBinding: _TestBinding()));
    await tester.pumpAndSettle();

    expect(find.text('Envoyez vos colis en toute simplicité'), findsOneWidget);
    expect(Get.isRegistered<DioClient>(), isTrue);
    expect(Get.isRegistered<SecureStorageService>(), isTrue);
  });
}

class _TestBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AppConfig>(
      const AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: 'http://127.0.0.1:3000',
      ),
      permanent: true,
    );
    Get.put<SecureStorageService>(
      SecureStorageService(_MemoryStore()),
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

class _MemoryStore implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<void> delete({required String key}) async => values.remove(key);

  @override
  Future<void> deleteAll() async => values.clear();

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}