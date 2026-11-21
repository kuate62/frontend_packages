import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../models/shipment_request.dart';
import '../repositories/shipment_requests_repository.dart';

class ShipmentRequestController extends GetxController {
  ShipmentRequestController(this._repository);

  final ShipmentRequestsRepository _repository;

  final step = 0.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final createdRequest = Rxn<ShipmentRequest>();

  final tenantId = RxnString();
  final tenantName = RxnString();

  final pickupCityController = TextEditingController();
  final pickupAddressController = TextEditingController();
  final deliveryCityController = TextEditingController();
  final deliveryAddressController = TextEditingController();
  final recipientFirstNameController = TextEditingController();
  final recipientLastNameController = TextEditingController();
  final recipientPhoneController = TextEditingController();
  final descriptionController = TextEditingController();
  final weightController = TextEditingController();

  @override
  void onClose() {
    pickupCityController.dispose();
    pickupAddressController.dispose();
    deliveryCityController.dispose();
    deliveryAddressController.dispose();
    recipientFirstNameController.dispose();
    recipientLastNameController.dispose();
    recipientPhoneController.dispose();
    descriptionController.dispose();
    weightController.dispose();
    super.onClose();
  }

  void next() {
    if (step.value < 6) step.value++;
  }

  void back() {
    if (step.value > 0) step.value--;
  }

  Future<bool> submit() async {
    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final request = await _repository.create(<String, dynamic>{
        'tenantId': tenantId.value,
        'pickupCity': pickupCityController.text.trim(),
        'pickupAddress': pickupAddressController.text.trim(),
        'deliveryCity': deliveryCityController.text.trim(),
        'deliveryAddress': deliveryAddressController.text.trim(),
        'recipientFirstName': recipientFirstNameController.text.trim(),
        'recipientLastName': recipientLastNameController.text.trim(),
        'recipientPhone': recipientPhoneController.text.trim(),
        'description': descriptionController.text.trim(),
        'weightKg': double.tryParse(weightController.text.trim()) ?? 0,
      });
      createdRequest.value = request;
      return true;
    } catch (error) {
      errorMessage.value = 'Impossible de créer la demande.';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}