import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';

import '../repositories/claims_repository.dart';

class ClaimDetailPage extends StatefulWidget {
  const ClaimDetailPage({super.key});

  @override
  State<ClaimDetailPage> createState() => _ClaimDetailPageState();
}

class _ClaimDetailPageState extends State<ClaimDetailPage> {
  Map<String, dynamic>? _claim;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = Get.arguments as String?;
    if (id == null) return;
    final repo = Get.find<ClaimsRepository>();
    final claim = await repo.getMyClaim(id);
    final history = await repo.getHistory(id);
    setState(() {
      _claim = <String, dynamic>{
        'id': claim.id,
        'reference': claim.reference,
        'category': claim.category,
        'subject': claim.subject,
        'description': claim.description,
        'status': claim.status,
        'resolution': claim.resolution,
      };
      _history = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final claim = _claim;
    if (claim == null) {
      return const Scaffold(body: Center(child: Text('Réclamation introuvable')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(claim['reference'] as String)),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: ListView(
          children: [
            Text('Statut : ${claim['status']}'),
            Text('Catégorie : ${claim['category']}'),
            Text('Objet : ${claim['subject']}'),
            Text('Description : ${claim['description']}'),
            if (claim['resolution'] != null) Text('Résolution : ${claim['resolution']}'),
            const SizedBox(height: AppDimensions.md),
            const Text('Historique', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._history.map((e) => Text('${e['actionType']} - ${e['createdAt']}')),
          ],
        ),
      ),
    );
  }
}