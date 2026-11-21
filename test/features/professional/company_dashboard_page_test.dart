import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend_packages/features/auth/controllers/auth_controller.dart';
import 'package:frontend_packages/features/auth/models/auth_models.dart';
import 'package:frontend_packages/features/auth/repositories/auth_repository.dart';
import 'package:frontend_packages/core/storage/secure_key_value_store.dart';
import 'package:frontend_packages/core/storage/secure_storage_service.dart';
import 'package:frontend_packages/features/professional/controllers/company_dashboard_controller.dart';
import 'package:frontend_packages/features/professional/models/company_dashboard_data.dart';
import 'package:frontend_packages/features/professional/pages/company_dashboard_page.dart';
import 'package:frontend_packages/features/professional/repositories/company_dashboard_repository.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockCompanyDashboardRepository extends CompanyDashboardRepository {
  _MockCompanyDashboardRepository() : super(Dio());

  CompanyDashboardData? mockData;
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<CompanyDashboardData> getOverview() async {
    callCount++;
    if (shouldThrow) {
      throw StateError('Erreur réseau simulée');
    }
    return mockData ?? _defaultCompanyData;
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

final _defaultCompanyData = CompanyDashboardData(
  company: const CompanyInfo(
    id: 'tenant-alpha-id',
    name: 'Trans Express Alpha',
    code: 'TEA-01',
    status: 'ACTIVE',
    totalAgencies: 4,
    totalAgents: 12,
    totalCustomers: 85,
    totalParcels: 250,
    totalTrips: 45,
  ),
  parcels: const CompanyParcelsStats(
    created: 250,
    total: 250,
    currentByStatus: {
      'REGISTERED': 30,
      'LOADED': 20,
      'IN_TRANSIT': 40,
      'ARRIVED': 15,
      'DELIVERED': 140,
      'CANCELLED': 5,
    },
    withIncidents: 2,
  ),
  transport: const CompanyTransportStats(
    tripsCreated: 45,
    total: 45,
    tripsByStatus: {
      'PLANNED': 10,
      'READY_FOR_DEPARTURE': 5,
      'IN_TRANSIT': 8,
      'ARRIVED': 22,
    },
    vehiclesByStatus: {'ACTIVE': 6},
    activeVehicles: 6,
  ),
  financial: const CompanyFinancialStats(
    byCurrency: {
      'XAF': FinancialCurrencyStats(
        payments: 520000,
        refunds: 20000,
        net: 500000,
        paymentCount: 80,
        refundCount: 2,
      ),
    },
    byMode: {
      'CASH': FinancialModeStats(count: 60, amount: 380000),
      'MOBILE_MONEY': FinancialModeStats(count: 20, amount: 140000),
    },
    note: 'Paiements enregistrés dans la plateforme (guichet V1).',
  ),
  recent: const CompanyRecentActivity(
    parcels: [
      RecentParcelItem(
        id: 'p-1',
        trackingCode: 'TEA-8841',
        status: 'IN_TRANSIT',
        description: 'Colis fragile documents',
      ),
    ],
    trips: [
      RecentTripItem(
        id: 'tr-100234',
        status: 'PLANNED',
        plannedDepartureAt: '2026-11-21T18:00:00Z',
      ),
    ],
    payments: [
      RecentPaymentItem(
        id: 'pay-1',
        type: 'PAYMENT',
        mode: 'CASH',
        amount: 15000,
        currency: 'XAF',
        status: 'CONFIRMED',
      ),
    ],
  ),
);

final _emptyCompanyData = CompanyDashboardData(
  company: const CompanyInfo(
    id: 'tenant-empty-id',
    name: 'Société Nouvelle',
    code: 'SN-01',
    status: 'ACTIVE',
    totalAgencies: 0,
    totalAgents: 0,
    totalCustomers: 0,
    totalParcels: 0,
    totalTrips: 0,
  ),
  parcels: const CompanyParcelsStats(
    created: 0,
    total: 0,
    currentByStatus: {},
    withIncidents: 0,
  ),
  transport: const CompanyTransportStats(
    tripsCreated: 0,
    total: 0,
    tripsByStatus: {},
    vehiclesByStatus: {},
    activeVehicles: 0,
  ),
  financial: const CompanyFinancialStats(
    byCurrency: {},
    byMode: {},
    note: '',
  ),
  recent: const CompanyRecentActivity(),
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> pumpCompanyDashboardPage(
  WidgetTester tester,
  CompanyDashboardController controller,
) async {
  await tester.pumpWidget(
    GetMaterialApp(
      home: Builder(
        builder: (context) {
          Get.put<CompanyDashboardController>(controller, permanent: true);
          return const CompanyDashboardPage();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _MockCompanyDashboardRepository mockRepo;
  late CompanyDashboardController controller;

  setUp(() {
    Get.testMode = true;
    mockRepo = _MockCompanyDashboardRepository();
    controller = CompanyDashboardController(mockRepo);
    Get.put<CompanyDashboardRepository>(mockRepo, permanent: true);

    // Initialiser AuthController requis par la page
    final authCtrl = AuthController(
      repository: _MockAuthRepository(),
      secureStorage: SecureStorageService(_MemoryStore()),
    );
    authCtrl.user.value = const User(
      id: 'usr-admin',
      email: 'admin@alpha.cm',
      firstName: 'Admin',
      lastName: 'Alpha',
      status: 'ACTIVE',
      isPlatformAdmin: false,
      memberships: [],
    );
    Get.put<AuthController>(authCtrl, permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  // -------------------------------------------------------------------------
  // 1. Affichage du nom de l'entreprise et des statistiques générales
  // -------------------------------------------------------------------------

  testWidgets('1. Affichage du nom de l entreprise et des statistiques générales', (tester) async {
    mockRepo.mockData = _defaultCompanyData;
    await pumpCompanyDashboardPage(tester, controller);

    // Nom de l'entreprise dans l'AppBar et l'en-tête
    expect(find.text('Trans Express Alpha'), findsAtLeastNWidgets(1));
    expect(find.text('Code : TEA-01 · Statut : ACTIVE'), findsOneWidget);

    // Grille générale
    expect(find.text('Agences'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Agents actifs'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Clients inscrits'), findsOneWidget);
    expect(find.text('85'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 2. Affichage des statistiques colis et trajets
  // -------------------------------------------------------------------------

  testWidgets('2. Affichage des opérations de colis et de trajets avec badges de statut', (tester) async {
    mockRepo.mockData = _defaultCompanyData;
    await pumpCompanyDashboardPage(tester, controller);

    // Colis
    expect(find.text('Total : 250 colis'), findsOneWidget);
    expect(find.text('2 incident(s)'), findsOneWidget);
    expect(find.text('En attente: 30'), findsOneWidget);
    expect(find.text('En transit: 60'), findsOneWidget);
    expect(find.text('Livrés: 140'), findsOneWidget);

    // Trajets
    expect(find.text('Total : 45 trajet(s)'), findsOneWidget);
    expect(find.text('6 véhicule(s) actif(s)'), findsOneWidget);
    expect(find.text('Planifiés: 10'), findsOneWidget);
    expect(find.text('Prêts au départ: 5'), findsOneWidget);
    expect(find.text('Arrivés: 22'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 3. Affichage des indicateurs financiers
  // -------------------------------------------------------------------------

  testWidgets('3. Affichage des indicateurs financiers guichet V1 et ventilation par mode', (tester) async {
    mockRepo.mockData = _defaultCompanyData;
    await pumpCompanyDashboardPage(tester, controller);

    expect(find.text('Encaissements nets (Guichet)'), findsOneWidget);
    expect(find.text('500000 XAF'), findsOneWidget);
    expect(find.text('82 opération(s)'), findsOneWidget);
    expect(find.text('CASH'), findsOneWidget);
    expect(find.text('MOBILE_MONEY'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 4. Affichage de l'activité récente
  // -------------------------------------------------------------------------

  testWidgets('4. Affichage de l activité récente de l entreprise', (tester) async {
    mockRepo.mockData = _defaultCompanyData;
    await pumpCompanyDashboardPage(tester, controller);

    expect(find.text('TEA-8841'), findsOneWidget);
    expect(find.text('Colis fragile documents · Statut: IN_TRANSIT'), findsOneWidget);
    expect(find.text('Trajet #100234'), findsOneWidget);
    expect(find.text('15000 XAF (CASH)'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 5. État vide
  // -------------------------------------------------------------------------

  testWidgets('5. État vide lorsque l entreprise n a aucune donnée', (tester) async {
    mockRepo.mockData = _emptyCompanyData;
    await pumpCompanyDashboardPage(tester, controller);

    expect(find.text('Aucune activité enregistrée pour cette entreprise.'), findsOneWidget);
    expect(find.text('Actualiser'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 6. État d'erreur et réessai
  // -------------------------------------------------------------------------

  testWidgets('6. État d erreur avec bouton Réessayer en cas d incident réseau', (tester) async {
    mockRepo.shouldThrow = true;
    await pumpCompanyDashboardPage(tester, controller);

    expect(find.text('Impossible de charger les statistiques de l\'entreprise.'), findsOneWidget);
    expect(find.byKey(const Key('company_retry_btn')), findsOneWidget);

    mockRepo.shouldThrow = false;
    mockRepo.mockData = _defaultCompanyData;
    await tester.tap(find.byKey(const Key('company_retry_btn')));
    await tester.pumpAndSettle();

    expect(find.text('Trans Express Alpha'), findsAtLeastNWidgets(1));
  });

  // -------------------------------------------------------------------------
  // 7. Bouton d'actualisation
  // -------------------------------------------------------------------------

  testWidgets('7. Bouton d actualisation dans l AppBar relance le chargement', (tester) async {
    mockRepo.mockData = _defaultCompanyData;
    await pumpCompanyDashboardPage(tester, controller);

    final initialCount = mockRepo.callCount;
    await tester.tap(find.byKey(const Key('company_refresh_btn')));
    await tester.pumpAndSettle();

    expect(mockRepo.callCount, greaterThan(initialCount));
  });
}
