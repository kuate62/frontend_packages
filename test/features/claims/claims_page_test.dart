import 'package:dio/dio.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend_packages/features/claims/controllers/claims_controller.dart';
import 'package:frontend_packages/features/claims/models/claim.dart';
import 'package:frontend_packages/features/claims/pages/claims_page.dart';
import 'package:frontend_packages/features/claims/repositories/claims_repository.dart';

class _FakeClaimsRepository extends ClaimsRepository {
  _FakeClaimsRepository() : super(_dummyDio());

  static Dio _dummyDio() => Dio();

  @override
  Future<List<Claim>> listMyClaims() async => <Claim>[];

  @override
  Future<Claim> getMyClaim(String id) async => const Claim(
        id: 'c1',
        reference: 'CLM-1',
        category: 'DELAY',
        subject: 'Sujet',
        description: 'Description',
        status: 'OPEN',
      );

  @override
  Future<List<Map<String, dynamic>>> getHistory(String id) async => <Map<String, dynamic>>[];
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('affiche un état vide', (tester) async {
    Get.put<ClaimsRepository>(_FakeClaimsRepository(), permanent: true);
    Get.put<ClaimsController>(ClaimsController(Get.find<ClaimsRepository>()), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: ClaimsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Aucune réclamation'), findsOneWidget);
  });
}