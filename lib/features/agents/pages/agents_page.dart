import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../controllers/agents_controller.dart';


class AgentsPage extends GetView<AgentsController> {
  const AgentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agents')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.agentCreate),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!));
        }
        if (controller.agents.isEmpty) {
          return const Center(child: Text('Aucun agent'));
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.builder(
            itemCount: controller.agents.length,
            itemBuilder: (context, index) {
              final agent = controller.agents[index];
              return Card(
                margin: const EdgeInsets.all(AppDimensions.sm),
                child: ListTile(
                  title: Text(agent.fullName.isEmpty ? agent.email : agent.fullName),
                  subtitle: Text('${agent.email} - ${agent.role ?? ''}'),
                  trailing: Text(agent.status),
                  onTap: () => Get.toNamed(AppRoutes.agentDetail, arguments: agent.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}