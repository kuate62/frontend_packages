import 'package:get/get.dart';

import '../../parcels/repositories/parcels_repository.dart';

class ReceptionController extends GetxController {
  ReceptionController(this._repository);

  final ParcelsRepository _repository;

  final parcels = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final events = <Map<String, dynamic>>[].obs;

  Future<void> loadExpected() async {
    await _load(status: 'ARRIVED');
  }

  Future<void> loadReady() async {
    await _load(status: 'READY_FOR_PICKUP');
  }

  Future<void> _load({required String status}) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      parcels.assignAll(await _repository.list(status: status));
    } catch (_) {
      errorMessage.value = 'Impossible de charger les colis.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> receive(String id) async {
    try {
      final data = await _repository.receive(id);
      return data['pickupCode'] as String?;
    } catch (_) {
      errorMessage.value = 'Réception impossible.';
      return null;
    }
  }

  Future<bool> deliver(String id, String code) async {
    try {
      await _repository.deliver(id, code);
      return true;
    } catch (_) {
      errorMessage.value = 'Remise impossible.';
      return false;
    }
  }

  Future<void> loadEvents(String id) async {
    try {
      events.assignAll(await _repository.events(id));
    } catch (_) {
      events.clear();
    }
  }

  Future<bool> returnParcel(String id, String comment) async {
    try {
      await _repository.returnParcel(id, comment);
      return true;
    } catch (_) {
      errorMessage.value = 'Retour impossible.';
      return false;
    }
  }
}