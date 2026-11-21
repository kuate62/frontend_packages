import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/dio_client.dart';


class ParcelWaybillPage extends StatelessWidget {
  const ParcelWaybillPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String?;
    return Scaffold(
      appBar: AppBar(title: const Text('Bordereau')),
      body: Center(
        child: ElevatedButton(
          onPressed: id == null
              ? null
              : () async {
                  final base = Get.find<DioClient>().dio.options.baseUrl.replaceAll('/api/v1/', '');
                  final uri = Uri.parse('$base/api/v1/documents/parcels/$id/waybill');
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
          child: const Text('Ouvrir le bordereau PDF'),
        ),
      ),
    );
  }
}