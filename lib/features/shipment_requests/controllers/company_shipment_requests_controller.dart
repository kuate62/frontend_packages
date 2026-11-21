import 'package:get/get.dart';


import '../../shipments/repositories/shipment_requests_repository.dart';
import '../../shipments/models/shipment_request.dart';

class CompanyShipmentRequestsController extends GetxController {
  CompanyShipmentRequestsController(this._repository);

  final ShipmentRequestsRepository _repository;

  final requests = <ShipmentRequest>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final statusFilter = 'SUBMITTED'.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      requests.assignAll(await _repository.listCompany(status: statusFilter.value));
    } catch (_) {
      errorMessage.value = 'Impossible de charger les demandes.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> accept(String id) async {
    try {
      await _repository.accept(id);
      await load();
    } catch (_) {
      errorMessage.value = 'Impossible d’accepter la demande.';
    }
  }

  Future<void> reject(String id, String reason) async {
    try {
      await _repository.reject(id, reason);
      await load();
    } catch (_) {
      errorMessage.value = 'Impossible de refuser la demande.';
    }
  }
}