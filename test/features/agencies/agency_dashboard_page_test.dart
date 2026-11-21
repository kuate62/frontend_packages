import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend_packages/features/auth/controllers/auth_controller.dart';
import 'package:frontend_packages/features/auth/models/auth_models.dart';
import 'package:frontend_packages/features/auth/repositories/auth_repository.dart';
import 'package:frontend_packages/core/storage/secure_key_value_store.dart';
import 'package:frontend_packages/core/storage/secure_storage_service.dart';
import 'package:frontend_packages/features/agencies/controllers/agency_dashboard_controller.dart';
import 'package:frontend_packages/features/agencies/models/agency_dashboard_data.dart';
import 'package:frontend_packages/features/agencies/pages/agency_dashboard_page.dart';
import 'package:frontend_packages/features/agencies/repositories/agency_dashboard_repository.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockAgencyDashboardRepository extends AgencyDashboardRepository {
  _MockAgencyDashboardRepository() : super(Dio());

  AgencyDashboardData? mockData;
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<AgencyDashboardData> getOverview() async {
    callCount++;
    if (shouldThrow) {
      throw StateError('Erreur réseau simulée');
    }
    return mockData ?? _defaultAgencyData;
  }
}

class _MockAuthRepository extends AuthRepository {
  _MockAuthRepository() : super(Dio());
  @override
  Future<void> logout() async {}
}

class _MemoryStore implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<void> delete({required String key}) async => values.remove(key);

  @override
  Future<void> deleteAll() async => values.clear();

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}

// ---------------------------------------------------------------------------
// Données de test
// ---------------------------------------------------------------------------

final _defaultAgencyData = AgencyDashboardData(
  agency: const AgencyScopeInfo(
    id: 'agency-akwa-01',
    name: 'Agence Akwa Express',
    code: 'AG-AKW-01',
    city: 'Douala',
    status: 'ACTIVE',
    totalAgents: 3,
    agents: [
      AgentSummary(
        id: 'agent-1',
        firstName: 'Paul',
        lastName: 'Biya',
        email: 'paul.biya@example.com',
        roleCode: 'AGENT',
        roleLabel: 'Agent de Guichet',
        status: 'ACTIVE',
        parcelsCount: 14,
      ),
      AgentSummary(
        id: 'agent-2',
        firstName: 'Jean',
        lastName: 'Nkuete',
        email: 'jean.nkuete@example.com',
        roleCode: 'AGENT',
        roleLabel: 'Agent de Guichet',
        status: 'ACTIVE',
        parcelsCount: 8,
      ),
    ],
  ),
  parcels: const AgencyParcelsStats(
    created: 22,
    total: 22,
    currentByStatus: {
      'REGISTERED': 5,
      'WAITING_FOR_TRANSPORT': 4,
      'LOADED': 2,
      'IN_TRANSIT': 3,
      'ARRIVED': 2,
      'READY_FOR_PICKUP': 1,
      'DELIVERED': 5,
    },
    withIncidents: 1,
  ),
  financial: const AgencyFinancialStats(
    byCurrency: {
      'XAF': FinancialCurrencyStats(
        payments: 45000,
        refunds: 5000,
        net: 40000,
        paymentCount: 4,
        refundCount: 1,
      ),
    },
    byMode: {
      'CASH': FinancialModeStats(count: 3, amount: 35000),
      'MOBILE_MONEY': FinancialModeStats(count: 2, amount: 15000),
    },
    note: 'Paiements enregistrés dans la plateforme (guichet V1).',
  ),
  recent: const AgencyRecentActivity(
    parcels: [
      RecentParcelItem(
        id: 'p-1',
        trackingCode: 'EXP-AKW-001',
        status: 'WAITING_FOR_TRANSPORT',
        description: 'Colis électronique Akwa',
      ),
      RecentParcelItem(
        id: 'p-2',
        trackingCode: 'EXP-AKW-002',
        status: 'DELIVERED',
        description: 'Médicaments urgents',
      ),
    ],
    payments: [
      RecentPaymentItem(
        id: 'pay-1',
        type: 'PAYMENT',
        mode: 'CASH',
        amount: 25000,
        currency: 'XAF',
        status: 'CONFIRMED',
      ),
      RecentPaymentItem(
        id: 'pay-2',
        type: 'REFUND',
        mode: 'CASH',
        amount: 5000,
        currency: 'XAF',
        status: 'CONFIRMED',
      ),
    ],
  ),
);

final _emptyAgencyData = AgencyDashboardData(
  agency: const AgencyScopeInfo(
    id: 'agency-empty-01',
    name: 'Agence Nouvelle',
    code: 'AG-NEW-01',
    city: 'Yaoundé',
    status: 'ACTIVE',
    totalAgents: 0,
    agents: [],
  ),
  parcels: const AgencyParcelsStats(
    created: 0,
    total: 0,
    currentByStatus: {},
    withIncidents: 0,
  ),
  financial: const AgencyFinancialStats(
    byCurrency: {},
    byMode: {},
    note: '',
  ),
  recent: const AgencyRecentActivity(),
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> pumpAgencyDashboardPage(
  WidgetTester tester,
  AgencyDashboardController controller,
) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    GetMaterialApp(
      home: Builder(
        builder: (context) {
          Get.put<AgencyDashboardController>(controller, permanent: true);
          return const AgencyDashboardPage();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _MockAgencyDashboardRepository mockRepo;

  setUp(() {
    Get.testMode = true;
    mockRepo = _MockAgencyDashboardRepository();
    Get.put<AgencyDashboardRepository>(mockRepo, permanent: true);

    final authCtrl = AuthController(
      repository: _MockAuthRepository(),
      secureStorage: SecureStorageService(_MemoryStore()),
    );
    authCtrl.user.value = const User(
      id: 'usr-agency-manager',
      email: 'manager.akwa@example.com',
      firstName: 'Chef',
      lastName: 'Akwa',
      status: 'ACTIVE',
      isPlatformAdmin: false,
      memberships: [],
    );
    Get.put<AuthController>(authCtrl, permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('1. Affichage du nom et code de l agence dans l en-tête', (tester) async {
    final controller = AgencyDashboardController(mockRepo);
    await pumpAgencyDashboardPage(tester, controller);

    expect(find.byKey(const Key('agency_header_name')), findsOneWidget);
    expect(find.text('Agence Akwa Express'), findsWidgets);
    expect(find.textContaining('Code: AG-AKW-01'), findsOneWidget);
    expect(find.textContaining('Ville: Douala'), findsOneWidget);
  });

  testWidgets('2. Affichage des KPIs principaux (Colis et Agents actifs)', (tester) async {
    final controller = AgencyDashboardController(mockRepo);
    await pumpAgencyDashboardPage(tester, controller);

    expect(find.byKey(const Key('kpi_parcels_val')), findsOneWidget);
    expect(find.text('22'), findsWidgets);
    expect(find.byKey(const Key('kpi_agents_val')), findsOneWidget);
    expect(find.text('3'), findsWidgets);
  });

  testWidgets('3. Affichage des statuts détaillés de colis et incident', (tester) async {
    final controller = AgencyDashboardController(mockRepo);
    await pumpAgencyDashboardPage(tester, controller);

    expect(find.text('Suivi des Colis'), findsOneWidget);
    expect(find.byKey(const Key('agency_parcel_status_REGISTERED')), findsOneWidget);
    expect(find.byKey(const Key('agency_parcel_status_DELIVERED')), findsOneWidget);
    expect(find.textContaining('1 incident(s)'), findsOneWidget);
  });

  testWidgets('4. Affichage des indicateurs financiers au guichet V1', (tester) async {
    final controller = AgencyDashboardController(mockRepo);
    await pumpAgencyDashboardPage(tester, controller);

    expect(find.text('Paiements au Guichet (V1)'), findsOneWidget);
    expect(find.byKey(const Key('agency_net_XAF')), findsOneWidget);
    expect(find.text('40000 XAF'), findsOneWidget);
    expect(find.textContaining('+45000 XAF'), findsOneWidget);
    expect(find.textContaining('Remboursements (1): -5000 XAF'), findsOneWidget);
    expect(find.textContaining('guichet V1'), findsOneWidget);
  });

  testWidgets('5. Affichage de la liste des agents de l agence', (tester) async {
    final controller = AgencyDashboardController(mockRepo);
    await pumpAgencyDashboardPage(tester, controller);

    expect(find.text('Agents de l\'Agence (2)'), findsOneWidget);
    expect(find.text('Paul Biya'), findsOneWidget);
    expect(find.text('Jean Nkuete'), findsOneWidget);
    expect(find.text('14 colis'), findsOneWidget);
    expect(find.text('8 colis'), findsOneWidget);
  });

  testWidgets('6. Affichage de l activité récente (colis et paiements)', (tester) async {
    final controller = AgencyDashboardController(mockRepo);
    await pumpAgencyDashboardPage(tester, controller);

    expect(find.text('Activité Récente'), findsOneWidget);
    expect(find.text('EXP-AKW-001'), findsOneWidget);
    expect(find.text('EXP-AKW-002'), findsOneWidget);
    expect(find.text('+25000 XAF'), findsOneWidget);
    expect(find.text('-5000 XAF'), findsOneWidget);
  });

  testWidgets('7. Bouton refresh déclenche un rechargement des données', (tester) async {
    final controller = AgencyDashboardController(mockRepo);
    await pumpAgencyDashboardPage(tester, controller);

    final initialCalls = mockRepo.callCount;
    await tester.tap(find.byKey(const Key('agency_refresh_btn')));
    await tester.pumpAndSettle();

    expect(mockRepo.callCount, greaterThan(initialCalls));
  });

  testWidgets('8. Affichage de l état vide lorsque l agence n a aucune donnée', (tester) async {
    mockRepo.mockData = _emptyAgencyData;
    final controller = AgencyDashboardController(mockRepo);
    await pumpAgencyDashboardPage(tester, controller);

    expect(find.text('Aucune activité enregistrée pour cette agence.'), findsOneWidget);
  });

  testWidgets('9. Gestion d erreur et bouton Réessayer', (tester) async {
    mockRepo.shouldThrow = true;
    final controller = AgencyDashboardController(mockRepo);
    await pumpAgencyDashboardPage(tester, controller);

    expect(find.byKey(const Key('agency_retry_btn')), findsOneWidget);
    expect(find.text('Impossible de charger les statistiques de l\'agence.'), findsOneWidget);

    // Clic sur Réessayer après retour à la normale
    mockRepo.shouldThrow = false;
    await tester.tap(find.byKey(const Key('agency_retry_btn')));
    await tester.pumpAndSettle();

    expect(find.text('Agence Akwa Express'), findsWidgets);
  });
}
