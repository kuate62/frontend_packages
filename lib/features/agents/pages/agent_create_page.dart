import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../controllers/agents_controller.dart';

class AgentCreatePage extends StatefulWidget {
  const AgentCreatePage({super.key});

  @override
  State<AgentCreatePage> createState() => _AgentCreatePageState();
}

class _AgentCreatePageState extends State<AgentCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _agencyIdController = TextEditingController();
  String _role = 'AGENT';

  @override
  void dispose() {
    _emailController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _agencyIdController.dispose();
    super.dispose();
  }

  Future<void> _submit(AgentsController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await controller.create(<String, dynamic>{
      'email': _emailController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'firstName': _firstNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      'role': _role,
      if (_agencyIdController.text.trim().isNotEmpty) 'agencyId': _agencyIdController.text.trim(),
    });
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgentsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel agent')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Email requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'Prénom')),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Téléphone requis' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (v) => (v == null || v.length < 10) ? 'Minimum 10 caractères' : null,
              ),
              const SizedBox(height: AppDimensions.sm),
              DropdownButtonFormField<String>(
                initialValue: _role,
                items: const [
                  DropdownMenuItem(value: 'AGENT', child: Text('Agent')),
                  DropdownMenuItem(value: 'DRIVER', child: Text('Chauffeur')),
                  DropdownMenuItem(value: 'AGENCY_MANAGER', child: Text('Responsable d’agence')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'AGENT'),
                decoration: const InputDecoration(labelText: 'Rôle'),
              ),
              const SizedBox(height: AppDimensions.sm),
              TextFormField(controller: _agencyIdController, decoration: const InputDecoration(labelText: 'ID agence (optionnel)')),
              const SizedBox(height: AppDimensions.lg),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () => _submit(controller),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Créer'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}