import 'package:get/get.dart';

import '../../trips/repositories/trips_repository.dart';

class DriverController extends GetxController {
  DriverController(this._repository);

  final TripsRepository _repository;

  final trips = <Map<String, dynamic>>[].obs;
  final selectedTrip = Rxn<Map<String, dynamic>>();
  final tripParcels = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadTrips();
  }

  Future<void> loadTrips() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final list = await _repository.list();
      trips.assignAll(list.map((t) => <String, dynamic>{
            'id': t.id,
            'status': t.status,
            'departure': t.departureAgency,
            'arrival': t.arrivalAgency,
            'departureAt': t.plannedDepartureAt,
          }).toList());
    } catch (_) {
      errorMessage.value = 'Impossible de charger les trajets.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openTrip(String id) async {
    try {
      final trip = await _repository.get(id);
      selectedTrip.value = <String, dynamic>{
        'id': trip.id,
        'status': trip.status,
        'departure': trip.departureAgency,
        'arrival': trip.arrivalAgency,
      };
      tripParcels.assignAll(await _repository.listTripParcels(id));
    } catch (_) {
      errorMessage.value = 'Impossible de charger le trajet.';
    }
  }

  Future<void> loadParcel(String tripId, String parcelId) async {
    try {
      await _repository.loadParcel(tripId, parcelId);
      await openTrip(tripId);
    } catch (_) {
      errorMessage.value = 'Chargement impossible.';
    }
  }

  Future<void> depart(String tripId) async {
    try {
      await _repository.depart(tripId);
      await openTrip(tripId);
    } catch (_) {
      errorMessage.value = 'Départ impossible.';
    }
  }

  Future<void> arrive(String tripId) async {
    try {
      await _repository.arrive(tripId);
      await openTrip(tripId);
    } catch (_) {
      errorMessage.value = 'Arrivée impossible.';
    }
  }

  Future<void> reportIncident(String parcelId, String type, String description) async {
    try {
      await _repository.reportIncident(parcelId, type, description);
    } catch (_) {
      errorMessage.value = 'Incident impossible à déclarer.';
    }
  }
}