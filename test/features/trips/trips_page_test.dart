import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend_packages/features/trips/controllers/trips_controller.dart';
import 'package:frontend_packages/features/trips/models/trip.dart';
import 'package:frontend_packages/features/trips/pages/trips_page.dart';
import 'package:frontend_packages/features/trips/repositories/trips_repository.dart';

class _FakeTripsRepository extends TripsRepository {
  _FakeTripsRepository() : super(_dummyDio());

  static Dio _dummyDio() => Dio();

  @override
  Future<List<Trip>> list({String? status, int page = 1, int limit = 50}) async => <Trip>[];

  @override
  Future<List<Map<String, dynamic>>> listAgencies() async => <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> listVehicles() async => <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> listDrivers() async => <Map<String, dynamic>>[];
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('affiche un état vide', (tester) async {
    final controller = TripsController(_FakeTripsRepository());
    controller.isLoading.value = false;
    Get.put<TripsController>(controller, permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: TripsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Aucun trajet'), findsOneWidget);
  });
}