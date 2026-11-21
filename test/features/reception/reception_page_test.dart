import 'package:dio/dio.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend_packages/features/parcels/repositories/parcels_repository.dart';
import 'package:frontend_packages/features/reception/bindings/reception_binding.dart';
import 'package:frontend_packages/features/reception/pages/reception_page.dart';

class _FakeParcelsRepository extends ParcelsRepository {
  _FakeParcelsRepository() : super(_dummyDio());

  static Dio _dummyDio() => Dio();

  @override
  Future<List<Map<String, dynamic>>> list({String? status, String? trackingCode, int page = 1, int limit = 50}) async =>
      <Map<String, dynamic>>[
        <String, dynamic>{'id': 'p1', 'trackingCode': 'TRK-1', 'status': 'READY_FOR_PICKUP'},
      ];

  @override
  Future<List<Map<String, dynamic>>> events(String id) async =>
      <Map<String, dynamic>>[
        <String, dynamic>{'eventType': 'RECEIVED', 'createdAt': '2026-01-01T00:00:00Z'},
      ];
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('affiche un colis et son historique', (tester) async {
    Get.put<ParcelsRepository>(_FakeParcelsRepository(), permanent: true);
    ReceptionBinding().dependencies();
    await tester.pumpWidget(const GetMaterialApp(home: ReceptionPage()));
    await tester.pumpAndSettle();

    expect(find.text('TRK-1'), findsOneWidget);

    await tester.tap(find.text('TRK-1'));
    await tester.pumpAndSettle();

    expect(find.text('RECEIVED'), findsOneWidget);
  });
}