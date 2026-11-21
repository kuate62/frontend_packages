import 'package:get/get.dart';

import '../models/vehicle.dart';
import '../repositories/vehicles_repository.dart';

class VehiclesController extends GetxController {
  VehiclesController(this._repository);

  final VehiclesRepository _repository;

  final vehicles = <Vehicle>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({String? status}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      vehicles.assignAll(await _repository.list(status: status));
    } catch (_) {
      errorMessage.value = 'Impossible de charger les véhicules.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(Map<String, dynamic> payload) async {
    try {
      final vehicle = await _repository.create(payload);
      vehicles.insert(0, vehicle);
      return true;
    } catch (_) {
      errorMessage.value = 'Impossible de créer le véhicule.';
      return false;
    }
  }

  Future<bool> deactivate(String id) async {
    try {
      final updated = await _repository.deactivate(id);
      final index = vehicles.indexWhere((item) => item.id == id);
      if (index != -1) vehicles[index] = updated;
      return true;
    } catch (_) {
      errorMessage.value = 'Impossible de désactiver le véhicule.';
      return false;
    }
  }
}