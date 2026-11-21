import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend_packages/features/super_admin/controllers/super_admin_users_controller.dart';
import 'package:frontend_packages/features/super_admin/models/app_user.dart';
import 'package:frontend_packages/features/super_admin/pages/super_admin_users_page.dart';
import 'package:frontend_packages/features/super_admin/repositories/users_repository.dart';

// ---------------------------------------------------------------------------
// Mock repository
// ---------------------------------------------------------------------------

class _MockUsersRepository extends UsersRepository {
  _MockUsersRepository() : super(Dio());

  List<AppUser> mockUsers = [];
  bool shouldThrow = false;

  @override
  Future<Map<String, dynamic>> list({
    String? search,
    String? tenantId,
    String? role,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    if (shouldThrow) throw StateError('Erreur réseau simulée');

    var items = List<AppUser>.from(mockUsers);

    // Filtrage simulé côté mock
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      items = items
          .where((u) =>
              u.firstName.toLowerCase().contains(q) ||
              u.lastName.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q))
          .toList();
    }
    if (status != null && status.isNotEmpty) {
      items = items.where((u) => u.status == status).toList();
    }

    return {
      'items': items,
      'total': items.length,
      'page': page,
      'limit': limit,
    };
  }

  @override
  Future<AppUser> getUser(String id) async {
    return mockUsers.firstWhere((u) => u.id == id);
  }

  @override
  Future<AppUser> setUserStatus(String id, String status) async {
    if (shouldThrow) throw StateError('Erreur réseau simulée');
    final user = mockUsers.firstWhere((u) => u.id == id);
    return AppUser(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      status: status,
      isPlatformAdmin: user.isPlatformAdmin,
      createdAt: user.createdAt,
      memberships: user.memberships,
    );
  }
}

// ---------------------------------------------------------------------------
// Données de test
// ---------------------------------------------------------------------------

final _alice = AppUser(
  id: 'u-alice',
  email: 'alice@example.com',
  firstName: 'Alice',
  lastName: 'Admin',
  phone: '+237699000001',
  status: 'ACTIVE',
  isPlatformAdmin: false,
  createdAt: '2025-01-01T00:00:00Z',
  memberships: [
    AppUserMembership(
      id: 'm-1',
      tenantId: 't-1',
      tenantName: 'Trans Express',
      role: 'TENANT_ADMIN',
      status: 'ACTIVE',
    ),
  ],
);

final _bob = AppUser(
  id: 'u-bob',
  email: 'bob@example.com',
  firstName: 'Bob',
  lastName: 'Agent',
  phone: '+237699000002',
  status: 'SUSPENDED',
  isPlatformAdmin: false,
  createdAt: '2025-02-01T00:00:00Z',
  memberships: [],
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> pumpUsersPage(WidgetTester tester, SuperAdminUsersController ctrl) async {
  await tester.pumpWidget(
    GetMaterialApp(
      home: Builder(
        builder: (context) {
          Get.put<SuperAdminUsersController>(ctrl, permanent: true);
          return const SuperAdminUsersPage();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _MockUsersRepository mockRepo;
  late SuperAdminUsersController controller;

  setUp(() {
    Get.testMode = true;
    mockRepo = _MockUsersRepository();
    mockRepo.mockUsers = [_alice, _bob];
    controller = SuperAdminUsersController(mockRepo);
    Get.put<UsersRepository>(mockRepo, permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  // -------------------------------------------------------------------------
  // 1. Affichage de la liste
  // -------------------------------------------------------------------------

  testWidgets('1. Affichage de la liste des utilisateurs', (tester) async {
    await pumpUsersPage(tester, controller);

    expect(find.text('Alice Admin'), findsOneWidget);
    expect(find.text('alice@example.com'), findsOneWidget);
    expect(find.text('Bob Agent'), findsOneWidget);
    expect(find.text('bob@example.com'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 2. État vide
  // -------------------------------------------------------------------------

  testWidgets('2. État vide : message affiché quand aucun utilisateur', (tester) async {
    mockRepo.mockUsers = [];
    await pumpUsersPage(tester, controller);

    expect(find.text('Aucun utilisateur trouvé.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  // -------------------------------------------------------------------------
  // 3. Recherche par nom
  // -------------------------------------------------------------------------

  testWidgets('3. Recherche filtre les utilisateurs par nom', (tester) async {
    await pumpUsersPage(tester, controller);

    // Saisir "Alice" dans le champ de recherche
    await tester.enterText(find.byKey(const Key('users_search_field')), 'Alice');
    await tester.pumpAndSettle();

    expect(find.text('Alice Admin'), findsOneWidget);
    expect(find.text('Bob Agent'), findsNothing);
  });

  // -------------------------------------------------------------------------
  // 4. Filtre par statut
  // -------------------------------------------------------------------------

  testWidgets('4. Filtre par statut SUSPENDED', (tester) async {
    await pumpUsersPage(tester, controller);

    // Ouvrir le dropdown de statut
    await tester.tap(find.byKey(const Key('status_filter')));
    await tester.pumpAndSettle();

    // Sélectionner SUSPENDED
    await tester.tap(find.text('SUSPENDED').last);
    await tester.pumpAndSettle();

    expect(find.text('Bob Agent'), findsOneWidget);
    expect(find.text('Alice Admin'), findsNothing);
  });

  // -------------------------------------------------------------------------
  // 5. Gestion des erreurs réseau
  // -------------------------------------------------------------------------

  testWidgets('5. Message d erreur affiché en cas d échec réseau', (tester) async {
    mockRepo.shouldThrow = true;
    await pumpUsersPage(tester, controller);

    expect(find.text('Impossible de charger les utilisateurs.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });

  // -------------------------------------------------------------------------
  // 6. Bouton de navigation vers les utilisateurs dans SuperAdminPage
  // -------------------------------------------------------------------------

  testWidgets('6. Badges de statut affichés dans les cartes', (tester) async {
    await pumpUsersPage(tester, controller);

    // Les deux badges de statut doivent être visibles
    expect(find.text('ACTIVE'), findsAtLeastNWidgets(1));
    expect(find.text('SUSPENDED'), findsAtLeastNWidgets(1));
  });
}
