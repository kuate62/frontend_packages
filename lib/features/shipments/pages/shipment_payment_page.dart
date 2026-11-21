import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../repositories/shipment_requests_repository.dart';

class ShipmentPaymentPage extends StatefulWidget {
  const ShipmentPaymentPage({super.key});

  @override
  State<ShipmentPaymentPage> createState() => _ShipmentPaymentPageState();
}

class _ShipmentPaymentPageState extends State<ShipmentPaymentPage> {
  bool _isLoading = false;
  bool _isPreparing = true;
  Map<String, dynamic>? _result;
  Map<String, dynamic>? _quote;
  String? _error;
  String? _requestId;

  @override
  void initState() {
    super.initState();
    _requestId = Get.arguments as String?;
    _prepare();
  }

  Future<void> _prepare() async {
    if (_requestId == null) {
      setState(() {
        _isPreparing = false;
        _error = 'Demande introuvable.';
      });
      return;
    }
    try {
      final dio = Get.find<DioClient>().dio;
      final response = await dio.get<Map<String, dynamic>>('/shipment-requests/$_requestId');
      final request = response.data?['data']?['shipmentRequest'] as Map<String, dynamic>?;
      final tenantId = request?['tenantId'] as String?;
      final weight = (request?['weightKg'] as num?)?.toDouble();
      if (tenantId != null && weight != null) {
        final quoteResponse = await dio.post<Map<String, dynamic>>(
          '/directory/companies/$tenantId/quote',
          data: <String, dynamic>{'weightKg': weight},
        );
        final data = quoteResponse.data?['data'] as Map<String, dynamic>?;
        if (data?['available'] == true) {
          _quote = data?['quote'] as Map<String, dynamic>?;
        }
      }
    } catch (_) {
      _error = 'Impossible de préparer le paiement.';
    } finally {
      setState(() => _isPreparing = false);
    }
  }

  Future<void> _pay() async {
    if (_requestId == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ShipmentRequestsRepository(Get.find<DioClient>().dio);
      final data = await repo.pay(_requestId!);
      setState(() => _result = data);
    } catch (_) {
      setState(() => _error = 'Paiement impossible.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Mode démonstration — aucun débit réel', style: AppTextStyles.body.copyWith(color: AppColors.warning)),
            const SizedBox(height: AppDimensions.lg),
            if (_isPreparing) const Center(child: CircularProgressIndicator()),
            if (!_isPreparing) ...[
              if (_quote != null) ...[
                Text('Montant : ${_quote!['total']} ${_quote!['currency']}', style: AppTextStyles.headline),
                const SizedBox(height: AppDimensions.sm),
              ],
              if (_error != null) Text(_error!, style: AppTextStyles.body.copyWith(color: AppColors.danger)),
              if (_result != null) ...[
                Text('Paiement confirmé', style: AppTextStyles.headline),
                const SizedBox(height: AppDimensions.sm),
                Text('Référence : ${_result!['payment']?['reference'] ?? ''}'),
                Text('Montant : ${_result!['payment']?['amount'] ?? ''} ${_result!['payment']?['currency'] ?? ''}'),
                const SizedBox(height: AppDimensions.md),
                ElevatedButton(
                  onPressed: () async {
                    final id = _result!['payment']?['id'] as String?;
                    if (id == null) return;
                    final base = Get.find<DioClient>().dio.options.baseUrl.replaceAll('/api/v1/', '');
                    final uri = Uri.parse('$base/api/v1/documents/payments/$id/receipt');
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  child: const Text('Télécharger le reçu'),
                ),
              ],
              const Spacer(),
              if (_result == null)
                SizedBox(
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _pay,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : const Text('Confirmer le paiement simulé'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}