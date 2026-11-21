import 'package:get/get.dart';

import '../models/trip.dart';
import '../repositories/trips_repository.dart';

class TripsController extends GetxController {
  TripsController(this._repository);

  final TripsRepository _repository;

  final trips = <Trip>[].obs;
  final agencies = <Map<String, dynamic>>[].obs;
  final vehicles = <Map<String, dynamic>>[].obs;
  final drivers = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final statusFilter = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({String? status}) async {
    if (status != null) statusFilter.value = status;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      trips.assignAll(await _repository.list(status: statusFilter.value));
      agencies.assignAll(await _repository.listAgencies());
      vehicles.assignAll(await _repository.listVehicles());
      drivers.assignAll(await _repository.listDrivers());
    } catch (_) {
      errorMessage.value = 'Impossible de charger les trajets.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> patch(String id, Map<String, dynamic> payload) async {
    try {
      final trip = await _repository.patch(id, payload);
      final index = trips.indexWhere((item) => item.id == id);
      if (index != -1) trips[index] = trip;
      return true;
    } catch (_) {
      errorMessage.value = 'Impossible de modifier le trajet.';
      return false;
    }
  }

  Future<bool> create(Map<String, dynamic> payload) async {
    try {
      final trip = await _repository.create(payload);
      trips.insert(0, trip);
      return true;
    } catch (_) {
      errorMessage.value = 'Impossible de créer le trajet.';
      return false;
    }
  }
}