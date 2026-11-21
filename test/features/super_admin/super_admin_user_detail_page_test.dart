import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend_packages/features/super_admin/models/app_user.dart';
import 'package:frontend_packages/features/super_admin/pages/super_admin_user_detail_page.dart';
import 'package:frontend_packages/features/super_admin/repositories/users_repository.dart';

// ---------------------------------------------------------------------------
// Mock repository
// ---------------------------------------------------------------------------

class _MockUsersRepository extends UsersRepository {
  _MockUsersRepository() : super(Dio());

  AppUser? userToReturn;
  bool shouldThrow = false;
  int setStatusCalls = 0;
  String? lastStatusSet;

  @override
  Future<Map<String, dynamic>> list({
    String? search,
    String? tenantId,
    String? role,
    String? status,
    int page = 1,
    int limit = 20,
  }) async =>
      {'items': <AppUser>[], 'total': 0, 'page': 1, 'limit': 20};

  @override
  Future<AppUser> getUser(String id) async {
    if (shouldThrow) throw StateError('Erreur réseau simulée');
    return userToReturn!;
  }

  @override
  Future<AppUser> setUserStatus(String id, String status) async {
    setStatusCalls++;
    lastStatusSet = status;
    if (shouldThrow) throw StateError('Erreur réseau simulée');
    return AppUser(
      id: userToReturn!.id,
      email: userToReturn!.email,
      firstName: userToReturn!.firstName,
      lastName: userToReturn!.lastName,
      phone: userToReturn!.phone,
      status: status,
      isPlatformAdmin: userToReturn!.isPlatformAdmin,
      createdAt: userToReturn!.createdAt,
      memberships: userToReturn!.memberships,
    );
  }
}

// ---------------------------------------------------------------------------
// Données de test
// ---------------------------------------------------------------------------

final _activeUser = AppUser(
  id: 'u-active',
  email: 'alice@example.com',
  firstName: 'Alice',
  lastName: 'Admin',
  phone: '+237699000001',
  status: 'ACTIVE',
  isPlatformAdmin: false,
  createdAt: '2025-01-15T10:00:00Z',
  memberships: [
    AppUserMembership(
      id: 'm-1',
      tenantId: 't-1',
      tenantName: 'Trans Express',
      tenantCode: 'TE',
      role: 'TENANT_ADMIN',
      roleLabel: 'Administrateur',
      agencyId: null,
      agencyName: null,
      status: 'ACTIVE',
      createdAt: '2025-01-15T10:00:00Z',
    ),
    AppUserMembership(
      id: 'm-2',
      tenantId: 't-2',
      tenantName: 'Cargo Plus',
      tenantCode: 'CP',
      role: 'AGENT',
      roleLabel: 'Agent',
      agencyId: 'ag-1',
      agencyName: 'Agence Centrale',
      status: 'SUSPENDED',
      createdAt: '2025-02-01T00:00:00Z',
    ),
  ],
);

final _suspendedUser = AppUser(
  id: 'u-suspended',
  email: 'bob@example.com',
  firstName: 'Bob',
  lastName: 'Agent',
  phone: '+237699000002',
  status: 'SUSPENDED',
  isPlatformAdmin: false,
  createdAt: '2025-03-01T00:00:00Z',
  memberships: [],
);

final _superAdminUser = AppUser(
  id: 'u-super',
  email: 'super@example.com',
  firstName: 'Super',
  lastName: 'Admin',
  phone: null,
  status: 'ACTIVE',
  isPlatformAdmin: true,
  createdAt: '2025-01-01T00:00:00Z',
  memberships: [],
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> pumpDetailPage(
  WidgetTester tester,
  UsersRepository repo,
  String userId,
) async {
  Get.put<UsersRepository>(repo, permanent: true);
  await tester.pumpWidget(
    GetMaterialApp(
      home: SuperAdminUserDetailPage(userId: userId),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _MockUsersRepository mockRepo;

  setUp(() {
    Get.testMode = true;
    mockRepo = _MockUsersRepository();
  });

  tearDown(() {
    Get.reset();
  });

  // -------------------------------------------------------------------------
  // 1. Affichage des informations personnelles
  // -------------------------------------------------------------------------

  testWidgets('1. Affichage des informations personnelles d un utilisateur ACTIVE', (tester) async {
    mockRepo.userToReturn = _activeUser;
    await pumpDetailPage(tester, mockRepo, 'u-active');

    expect(find.text('Alice Admin'), findsAtLeastNWidgets(1));
    expect(find.text('alice@example.com'), findsOneWidget);
    expect(find.text('+237699000001'), findsOneWidget);
    expect(find.byKey(const Key('user_status_text')), findsOneWidget);
    expect(find.text('ACTIVE'), findsAtLeastNWidgets(1));
  });

  // -------------------------------------------------------------------------
  // 2. Affichage des adhésions
  // -------------------------------------------------------------------------

  testWidgets('2. Affichage des adhésions avec leur statut', (tester) async {
    mockRepo.userToReturn = _activeUser;
    await pumpDetailPage(tester, mockRepo, 'u-active');

    expect(find.text('Trans Express'), findsOneWidget);
    expect(find.text('Cargo Plus'), findsOneWidget);
    // Statut des adhésions
    expect(find.text('ACTIVE'), findsAtLeastNWidgets(1));
    expect(find.text('SUSPENDED'), findsAtLeastNWidgets(1));
  });

  // -------------------------------------------------------------------------
  // 3. Bouton de suspension visible pour utilisateur ACTIVE non SUPER_ADMIN
  // -------------------------------------------------------------------------

  testWidgets('3. Bouton Suspendre visible pour utilisateur ACTIVE', (tester) async {
    mockRepo.userToReturn = _activeUser;
    await pumpDetailPage(tester, mockRepo, 'u-active');

    expect(find.byKey(const Key('toggle_user_status_button')), findsOneWidget);
    expect(find.text('Suspendre ce compte'), findsOneWidget);
    expect(find.text('Réactiver ce compte'), findsNothing);
  });

  // -------------------------------------------------------------------------
  // 4. Bouton de réactivation visible pour utilisateur SUSPENDED
  // -------------------------------------------------------------------------

  testWidgets('4. Bouton Réactiver visible pour utilisateur SUSPENDED', (tester) async {
    mockRepo.userToReturn = _suspendedUser;
    await pumpDetailPage(tester, mockRepo, 'u-suspended');

    expect(find.byKey(const Key('toggle_user_status_button')), findsOneWidget);
    expect(find.text('Réactiver ce compte'), findsOneWidget);
    expect(find.text('Suspendre ce compte'), findsNothing);
  });

  // -------------------------------------------------------------------------
  // 5. Pas de bouton de modification pour SUPER_ADMIN (isPlatformAdmin = true)
  // -------------------------------------------------------------------------

  testWidgets('5. Bouton de statut masqué pour utilisateur isPlatformAdmin', (tester) async {
    mockRepo.userToReturn = _superAdminUser;
    await pumpDetailPage(tester, mockRepo, 'u-super');

    expect(find.byKey(const Key('toggle_user_status_button')), findsNothing);
    expect(find.text('Super Admin'), findsAtLeastNWidgets(1));
  });

  // -------------------------------------------------------------------------
  // 6. Annulation de la confirmation sans modification
  // -------------------------------------------------------------------------

  testWidgets('6. Annulation du dialogue de confirmation : aucun appel API', (tester) async {
    mockRepo.userToReturn = _activeUser;
    await pumpDetailPage(tester, mockRepo, 'u-active');

    // Scroller jusqu'au bouton de statut (peut être hors écran)
    final btnFinder = find.byKey(const Key('toggle_user_status_button'));
    await tester.ensureVisible(btnFinder);
    await tester.pumpAndSettle();

    await tester.tap(btnFinder);
    await tester.pumpAndSettle();

    // Le dialogue apparaît
    expect(find.text('Confirmer la suspension'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);

    // Annulation
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(mockRepo.setStatusCalls, 0);
    expect(find.text('ACTIVE'), findsAtLeastNWidgets(1));
  });

  // -------------------------------------------------------------------------
  // 7. Confirmation de suspension — statut mis à jour
  // -------------------------------------------------------------------------

  testWidgets('7. Confirmation de suspension : statut mis à jour', (tester) async {
    mockRepo.userToReturn = _activeUser;
    await pumpDetailPage(tester, mockRepo, 'u-active');

    // Scroller jusqu'au bouton de statut
    final btnFinder = find.byKey(const Key('toggle_user_status_button'));
    await tester.ensureVisible(btnFinder);
    await tester.pumpAndSettle();

    await tester.tap(btnFinder);
    await tester.pumpAndSettle();

    expect(find.text('Confirmer la suspension'), findsOneWidget);

    // Confirmer
    await tester.tap(find.widgetWithText(FilledButton, 'Suspendre'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(mockRepo.setStatusCalls, 1);
    expect(mockRepo.lastStatusSet, 'SUSPENDED');

    // Scroller à nouveau pour voir le bouton mis à jour
    final updatedBtnFinder = find.byKey(const Key('toggle_user_status_button'));
    await tester.ensureVisible(updatedBtnFinder);
    await tester.pumpAndSettle();

    // Le bouton s'est mis à jour
    expect(find.text('Réactiver ce compte'), findsOneWidget);

    // Laisser le snackbar se fermer
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  // -------------------------------------------------------------------------
  // 8. Gestion d'erreur API lors du chargement
  // -------------------------------------------------------------------------

  testWidgets('8. Erreur de chargement : message d erreur et bouton Réessayer', (tester) async {
    mockRepo.shouldThrow = true;
    await pumpDetailPage(tester, mockRepo, 'u-any');

    expect(find.text('Impossible de charger cet utilisateur.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });
}
