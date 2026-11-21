import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../controllers/agents_controller.dart';


class AgentDetailPage extends StatelessWidget {
  const AgentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String?;
    final controller = Get.find<AgentsController>();
    final agent = controller.agents.firstWhereOrNull((a) => a.id == id);
    if (agent == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Agent')),
        body: const Center(child: Text('Agent introuvable')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(agent.fullName.isEmpty ? agent.email : agent.fullName)),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email : ${agent.email}'),
            Text('Téléphone : ${agent.phone ?? ''}'),
            Text('Rôle : ${agent.role ?? ''}'),
            Text('Agence : ${agent.agencyId ?? ''}'),
            Text('Statut : ${agent.status}'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.toggleStatus(agent),
                child: Text(agent.isActive ? 'Désactiver' : 'Activer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}