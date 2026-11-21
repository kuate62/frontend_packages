import 'package:get/get.dart';

import '../repositories/my_parcels_repository.dart';
import '../models/my_parcel.dart';

class MyParcelsController extends GetxController {
  MyParcelsController(this._repository);

  final MyParcelsRepository _repository;

  final parcels = <MyParcel>[].obs;
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
      parcels.assignAll(await _repository.listMyParcels());
    } catch (error) {
      errorMessage.value = 'Impossible de charger vos colis.';
    } finally {
      isLoading.value = false;
    }
  }
}