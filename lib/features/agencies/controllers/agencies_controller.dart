import 'package:get/get.dart';

import '../models/agency.dart';
import '../repositories/agencies_repository.dart';

class AgenciesController extends GetxController {
  AgenciesController(this._repository);

  final AgenciesRepository _repository;

  final agencies = <Agency>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      agencies.assignAll(await _repository.list());
    } catch (_) {
      errorMessage.value = 'Impossible de charger les agences.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(Map<String, dynamic> payload) async {
    try {
      final agency = await _repository.create(payload);
      agencies.insert(0, agency);
      return true;
    } catch (_) {
      errorMessage.value = 'Impossible de créer l’agence.';
      return false;
    }
  }

  Future<bool> updateAgency(String id, Map<String, dynamic> payload) async {
    try {
      final updated = await _repository.update(id, payload);
      final index = agencies.indexWhere((item) => item.id == id);
      if (index != -1) agencies[index] = updated;
      return true;
    } catch (_) {
      errorMessage.value = 'Impossible de modifier l’agence.';
      return false;
    }
  }

  Future<bool> deactivate(String id) async {
    try {
      final updated = await _repository.deactivate(id);
      final index = agencies.indexWhere((item) => item.id == id);
      if (index != -1) agencies[index] = updated;
      return true;
    } catch (_) {
      errorMessage.value = 'Impossible de désactiver l’agence.';
      return false;
    }
  }
}