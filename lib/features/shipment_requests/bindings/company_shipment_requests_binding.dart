import 'package:get/get.dart';

import '../../../core/network/dio_client.dart';
import '../../shipments/repositories/shipment_requests_repository.dart';
import '../controllers/company_shipment_requests_controller.dart';

class CompanyShipmentRequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipmentRequestsRepository>(
      () => ShipmentRequestsRepository(Get.find<DioClient>().dio),
      fenix: true,
    );
    Get.lazyPut<CompanyShipmentRequestsController>(
      () => CompanyShipmentRequestsController(Get.find<ShipmentRequestsRepository>()),
      fenix: true,
    );
  }
}