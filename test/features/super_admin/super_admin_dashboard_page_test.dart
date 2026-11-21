import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend_packages/features/super_admin/controllers/super_admin_dashboard_controller.dart';
import 'package:frontend_packages/features/super_admin/models/super_admin_dashboard_data.dart';
import 'package:frontend_packages/features/super_admin/pages/super_admin_dashboard_page.dart';
import 'package:frontend_packages/features/super_admin/repositories/super_admin_dashboard_repository.dart';

// ---------------------------------------------------------------------------
// Mock repository
// ---------------------------------------------------------------------------

class _MockDashboardRepository extends SuperAdminDashboardRepository {
  _MockDashboardRepository() : super(Dio());

  SuperAdminDashboardData? mockData;
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<SuperAdminDashboardData> getDashboard() async {
    callCount++;
    if (shouldThrow) {
      throw StateError('Erreur réseau simulée');
    }
    return mockData ?? _defaultData;
  }
}

// ---------------------------------------------------------------------------
// Données de test
// ---------------------------------------------------------------------------

final _defaultData = SuperAdminDashboardData(
  tenants: const DashboardTenants(total: 8, active: 6, suspended: 2),
  users: const DashboardUsers(total: 42, active: 38, suspended: 4, pending: 0),
  agenciesTotal: 15,
  parcels: const DashboardParcels(
    total: 120,
    byStatus: {
      'REGISTERED': 20,
      'IN_TRANSIT': 35,
      'ARRIVED': 15,
      'DELIVERED': 50,
    },
  ),
  trips: const DashboardTrips(
    total: 28,
    byStatus: {'PLANNED': 8, 'IN_TRANSIT': 5, 'ARRIVED': 15},
  ),
  payments: const DashboardPayments(
    total: 95,
    totalAmount: 1850000,
    currency: 'XAF',
    byMode: {
      'CASH': PaymentModeStats(count: 60, amount: 1200000),
      'MOBILE_MONEY': PaymentModeStats(count: 35, amount: 650000),
    },
    note: 'Paiements enregistrés dans la plateforme (guichet V1).',
  ),
  recent: const DashboardRecentActivity(
    tenants: [
      RecentTenantItem(id: 't-1', name: 'Logistique Express', city: 'Douala', status: 'ACTIVE'),
    ],
    users: [
      RecentUserItem(id: 'u-1', firstName: 'Jean', lastName: 'Dupont', email: 'jean@express.cm', status: 'ACTIVE'),
    ],
    parcels: [
      RecentParcelItem(id: 'p-1', trackingCode: 'EXP-9921', status: 'IN_TRANSIT', description: 'Carton pièces'),
    ],
  ),
);

final _emptyData = SuperAdminDashboardData(
  tenants: const DashboardTenants(total: 0, active: 0, suspended: 0),
  users: const DashboardUsers(total: 0, active: 0, suspended: 0, pending: 0),
  agenciesTotal: 0,
  parcels: const DashboardParcels(total: 0, byStatus: {}),
  trips: const DashboardTrips(total: 0, byStatus: {}),
  payments: const DashboardPayments(
    total: 0,
    totalAmount: 0,
    currency: 'XAF',
    byMode: {},
    note: '',
  ),
  recent: const DashboardRecentActivity(),
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> pumpDashboardPage(
  WidgetTester tester,
  SuperAdminDashboardController controller,
) async {
  await tester.pumpWidget(
    GetMaterialApp(
      home: Builder(
        builder: (context) {
          Get.put<SuperAdminDashboardController>(controller, permanent: true);
          return const SuperAdminDashboardPage();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _MockDashboardRepository mockRepo;
  late SuperAdminDashboardController controller;

  setUp(() {
    Get.testMode = true;
    mockRepo = _MockDashboardRepository();
    controller = SuperAdminDashboardController(mockRepo);
    Get.put<SuperAdminDashboardRepository>(mockRepo, permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  // -------------------------------------------------------------------------
  // 1. Affichage des statistiques globales
  // -------------------------------------------------------------------------

  testWidgets('1. Affichage des statistiques globales (entreprises, utilisateurs, colis, paiements)', (tester) async {
    mockRepo.mockData = _defaultData;
    await pumpDashboardPage(tester, controller);

    // Titre de page
    expect(find.text('Super Administrateur'), findsOneWidget);

    // Section entreprises & utilisateurs
    expect(find.text('Entreprises'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Utilisateurs'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Agences'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);

    // Section opérations
    expect(find.text('Total Colis'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('Total Trajets'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);

    // Section financière
    expect(find.text('Total Encaissé (Guichet)'), findsOneWidget);
    expect(find.text('1850000 XAF'), findsOneWidget);
    expect(find.text('95 paiement(s)'), findsOneWidget);
    expect(find.text('CASH'), findsOneWidget);
    expect(find.text('MOBILE_MONEY'), findsOneWidget);

    // Activité récente
    expect(find.text('Logistique Express'), findsOneWidget);
    expect(find.text('Jean Dupont'), findsOneWidget);
    expect(find.text('EXP-9921'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 2. État vide
  // -------------------------------------------------------------------------

  testWidgets('2. État vide lorsque aucune donnée statistique n est disponible', (tester) async {
    mockRepo.mockData = _emptyData;
    await pumpDashboardPage(tester, controller);

    expect(find.text('Aucune donnée statistique disponible.'), findsOneWidget);
    expect(find.text('Actualiser'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 3. État d erreur et réessai
  // -------------------------------------------------------------------------

  testWidgets('3. État d erreur avec bouton Réessayer en cas de panne réseau', (tester) async {
    mockRepo.shouldThrow = true;
    await pumpDashboardPage(tester, controller);

    expect(find.text('Impossible de charger les statistiques globales.'), findsOneWidget);
    expect(find.byKey(const Key('dashboard_retry_btn')), findsOneWidget);

    // Maintenant débloquer et cliquer sur Réessayer
    mockRepo.shouldThrow = false;
    mockRepo.mockData = _defaultData;
    await tester.tap(find.byKey(const Key('dashboard_retry_btn')));
    await tester.pumpAndSettle();

    expect(find.text('Entreprises'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 4. Actualisation des données (bouton refresh)
  // -------------------------------------------------------------------------

  testWidgets('4. Bouton refresh déclenche un rechargement des données', (tester) async {
    mockRepo.mockData = _defaultData;
    await pumpDashboardPage(tester, controller);

    final initialCalls = mockRepo.callCount;

    await tester.tap(find.byKey(const Key('dashboard_refresh_btn')));
    await tester.pumpAndSettle();

    expect(mockRepo.callCount, greaterThan(initialCalls));
  });

  // -------------------------------------------------------------------------
  // 5. Navigation vers les modules existants depuis le Dashboard
  // -------------------------------------------------------------------------

  testWidgets('5. Boutons de navigation vers les entreprises et utilisateurs présents', (tester) async {
    mockRepo.mockData = _defaultData;
    await pumpDashboardPage(tester, controller);

    expect(find.byKey(const Key('dashboard_nav_tenants_btn')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_nav_users_btn')), findsOneWidget);
  });
}
