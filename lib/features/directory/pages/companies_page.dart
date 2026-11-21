import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../core/theme/app_dimensions.dart';

import '../controllers/companies_controller.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompaniesController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Entreprises de transport')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher une entreprise',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => controller.load(search: value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Poids (kg)'),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                ElevatedButton(
                  onPressed: () {
                    final weight = double.tryParse(_weightController.text.trim());
                    if (weight != null) {
                      controller.compare(weight);
                    }
                  },
                  child: const Text('Comparer'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value != null) {
                return Center(child: Text(controller.errorMessage.value!));
              }
              if (controller.companies.isEmpty) {
                return const Center(child: Text('Aucune entreprise disponible'));
              }
              return ListView.builder(
                itemCount: controller.companies.length,
                itemBuilder: (context, index) {
                  final company = controller.companies[index];
                  final quote = controller.quotes[company.id];
                  return Card(
                    margin: const EdgeInsets.all(AppDimensions.sm),
                    child: ListTile(
                      title: Text(company.name),
                      subtitle: Text(company.city ?? ''),
                      trailing: quote == null
                          ? Text('${company.agencyCount} agences')
                          : Text('Tarif: ${quote['quote']?['total'] ?? 'n/a'}'),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}