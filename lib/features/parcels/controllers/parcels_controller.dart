import 'package:get/get.dart';


import '../repositories/parcels_repository.dart';

class ParcelsController extends GetxController {
  ParcelsController(this._repository);

  final ParcelsRepository _repository;

  final parcels = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final searchQuery = ''.obs;
  final statusFilter = RxnString();
  final events = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({String? status, String? trackingCode}) async {
    if (status != null) statusFilter.value = status;
    if (trackingCode != null) searchQuery.value = trackingCode;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      parcels.assignAll(await _repository.list(status: statusFilter.value, trackingCode: searchQuery.value));
    } catch (_) {
      errorMessage.value = 'Impossible de charger les colis.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadEvents(String id) async {
    try {
      events.assignAll(await _repository.events(id));
    } catch (_) {
      events.clear();
    }
  }
}