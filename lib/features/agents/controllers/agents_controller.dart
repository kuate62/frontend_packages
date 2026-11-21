import 'package:get/get.dart';

import '../models/agent.dart';
import '../repositories/agents_repository.dart';

class AgentsController extends GetxController {
  AgentsController(this._repository);

  final AgentsRepository _repository;

  final agents = <Agent>[].obs;
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
      agents.assignAll(await _repository.list());
    } catch (_) {
      errorMessage.value = 'Impossible de charger les agents.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(Map<String, dynamic> payload) async {
    try {
      final agent = await _repository.create(payload);
      agents.insert(0, agent);
      return true;
    } catch (_) {
      errorMessage.value = 'Impossible de créer l’agent.';
      return false;
    }
  }

  Future<bool> toggleStatus(Agent agent) async {
    try {
      final newStatus = agent.isActive ? 'SUSPENDED' : 'ACTIVE';
      await _repository.updateStatus(agent.id, newStatus);
      final index = agents.indexWhere((item) => item.id == agent.id);
      if (index != -1) {
        agents[index] = Agent(
          id: agent.id,
          email: agent.email,
          firstName: agent.firstName,
          lastName: agent.lastName,
          phone: agent.phone,
          status: newStatus,
          role: agent.role,
          roleLabel: agent.roleLabel,
          agencyId: agent.agencyId,
          membershipId: agent.membershipId,
        );
      }
      return true;
    } catch (_) {
      errorMessage.value = 'Impossible de modifier le statut.';
      return false;
    }
  }
}