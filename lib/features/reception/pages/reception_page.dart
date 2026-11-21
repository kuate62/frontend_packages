import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_dimensions.dart';
import '../controllers/reception_controller.dart';

class ReceptionPage extends StatefulWidget {
  const ReceptionPage({super.key});

  @override
  State<ReceptionPage> createState() => _ReceptionPageState();
}

class _ReceptionPageState extends State<ReceptionPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ReceptionController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = Get.find<ReceptionController>();
    _controller.loadExpected();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index == 0) {
        _controller.loadExpected();
      } else {
        _controller.loadReady();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réception'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Attendus'),
            Tab(text: 'À retirer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(isExpected: true),
          _buildList(isExpected: false),
        ],
      ),
    );
  }

  Widget _buildList({required bool isExpected}) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_controller.errorMessage.value != null) {
        return Center(child: Text(_controller.errorMessage.value!));
      }
      if (_controller.parcels.isEmpty) {
        return const Center(child: Text('Aucun colis'));
      }
      return ListView.builder(
        itemCount: _controller.parcels.length,
        itemBuilder: (context, index) {
          final parcel = _controller.parcels[index];
          final id = parcel['id'] as String;
          final code = parcel['trackingCode'] as String? ?? '';
          return Card(
            margin: const EdgeInsets.all(AppDimensions.sm),
            child: ListTile(
              title: Text(code),
              subtitle: Text(parcel['status'] as String? ?? ''),
              onTap: () async {
                await _controller.loadEvents(id);
                if (!context.mounted) return;
                showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => ListView(
                    children: _controller.events
                        .map((e) => ListTile(
                              title: Text(e['eventType']?.toString() ?? ''),
                              subtitle: Text(e['createdAt']?.toString() ?? ''),
                            ))
                        .toList(),
                  ),
                );
              },
              trailing: isExpected
                  ? ElevatedButton(
                      onPressed: () async {
                        final pickupCode = await _controller.receive(id);
                        if (pickupCode != null) {
                          Get.snackbar('Code OTP', pickupCode);
                        }
                      },
                      child: const Text('Réceptionner'),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        final codeController = TextEditingController();
                        final entered = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Code OTP'),
                            content: TextField(controller: codeController),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                              TextButton(onPressed: () => Navigator.pop(context, codeController.text), child: const Text('Valider')),
                            ],
                          ),
                        );
                        if (entered != null) {
                          final ok = await _controller.deliver(id, entered);
                          if (ok) Get.snackbar('Succès', 'Colis remis');
                        }
                      },
                      child: const Text('Remettre'),
                    ),
            ),
          );
        },
      );
    });
  }
}