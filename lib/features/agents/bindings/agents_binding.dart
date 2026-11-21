import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../controllers/agents_controller.dart';
import '../repositories/agents_repository.dart';

class AgentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgentsRepository>(
      () => AgentsRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<AgentsController>(
      () => AgentsController(Get.find<AgentsRepository>()),
      fenix: true,
    );
  }
}