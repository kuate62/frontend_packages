import 'package:get/get.dart';

import '../models/claim.dart';
import '../repositories/claims_repository.dart';

class ClaimsController extends GetxController {
  ClaimsController(this._repository);

  final ClaimsRepository _repository;

  final claims = <Claim>[].obs;
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
      claims.assignAll(await _repository.listMyClaims());
    } catch (_) {
      errorMessage.value = 'Impossible de charger les réclamations.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(Map<String, dynamic> payload) async {
    try {
      final claim = await _repository.createClaim(payload);
      claims.insert(0, claim);
      return true;
    } catch (_) {
      errorMessage.value = 'Impossible de créer la réclamation.';
      return false;
    }
  }
}