import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:frontend_packages/app/routes/app_routes.dart';
import 'package:frontend_packages/features/auth/repositories/auth_repository.dart';
import 'package:frontend_packages/features/auth/screens/forgot_password_page.dart';

class _MockAuthRepository extends AuthRepository {
  _MockAuthRepository() : super(Dio());

  String lastRequestedEmail = '';
  String lastResetEmail = '';
  String lastResetCode = '';
  String lastResetPassword = '';
  bool shouldThrow = false;

  @override
  Future<String> requestPasswordReset({required String email}) async {
    if (shouldThrow) throw StateError('Réseau indisponible');
    lastRequestedEmail = email;
    return 'Si cette adresse existe, un code vous a été envoyé.';
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (shouldThrow) throw StateError('Code invalide');
    lastResetEmail = email;
    lastResetCode = code;
    lastResetPassword = newPassword;
    return 'Mot de passe réinitialisé avec succès.';
  }
}

Future<void> pumpForgotPasswordPage(
  WidgetTester tester,
  _MockAuthRepository repo,
) async {
  Get.testMode = true;
  Get.put<AuthRepository>(repo, permanent: true);

  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: AppRoutes.forgotPassword,
      getPages: [
        GetPage(
          name: AppRoutes.forgotPassword,
          page: () => const ForgotPasswordPage(),
        ),
        GetPage(
          name: AppRoutes.login,
          page: () => const Scaffold(body: Text('Écran Login')),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _MockAuthRepository mockRepo;

  setUp(() {
    Get.reset();
    mockRepo = _MockAuthRepository();
  });

  tearDown(Get.reset);

  testWidgets('1. Affichage initial de l étape Email avec logo et bouton', (tester) async {
    await pumpForgotPasswordPage(tester, mockRepo);

    expect(find.text('Mot de passe oublié'), findsOneWidget);
    expect(find.text('Adresse e-mail de votre compte'), findsOneWidget);
    expect(find.text('Envoyer le code OTP'), findsOneWidget);
    expect(find.text('Retour à la connexion'), findsOneWidget);
  });

  testWidgets('2. Validation du formulaire email vide', (tester) async {
    await pumpForgotPasswordPage(tester, mockRepo);

    await tester.tap(find.text('Envoyer le code OTP'));
    await tester.pumpAndSettle();

    expect(find.text('Adresse e-mail requise.'), findsOneWidget);
  });

  testWidgets('3. Envoi du code réussi et transition vers l étape Code OTP', (tester) async {
    await pumpForgotPasswordPage(tester, mockRepo);

    await tester.enterText(find.byType(TextFormField).first, 'test@expressio.cm');
    await tester.tap(find.text('Envoyer le code OTP'));
    await tester.pumpAndSettle();

    expect(mockRepo.lastRequestedEmail, 'test@expressio.cm');
    expect(find.text('Code de vérification (6 chiffres)'), findsOneWidget);
    expect(find.text('Valider le code'), findsOneWidget);
  });

  testWidgets('4. Saisie du code OTP et passage à l étape Nouveau Mot de passe', (tester) async {
    await pumpForgotPasswordPage(tester, mockRepo);

    // Étape 1
    await tester.enterText(find.byType(TextFormField).first, 'test@expressio.cm');
    await tester.tap(find.text('Envoyer le code OTP'));
    await tester.pumpAndSettle();

    // Étape 2 (Code)
    await tester.enterText(find.byType(TextFormField).first, '123456');
    await tester.tap(find.text('Valider le code'));
    await tester.pumpAndSettle();

    expect(find.text('Nouveau mot de passe'), findsOneWidget);
    expect(find.text('Confirmer le nouveau mot de passe'), findsOneWidget);
    expect(find.text('Enregistrer le nouveau mot de passe'), findsOneWidget);
  });

  testWidgets('5. Réinitialisation réussie et affichage de l écran de succès', (tester) async {
    await pumpForgotPasswordPage(tester, mockRepo);

    // Étape 1
    await tester.enterText(find.byType(TextFormField).first, 'test@expressio.cm');
    await tester.tap(find.text('Envoyer le code OTP'));
    await tester.pumpAndSettle();

    // Étape 2
    await tester.enterText(find.byType(TextFormField).first, '123456');
    await tester.tap(find.text('Valider le code'));
    await tester.pumpAndSettle();

    // Étape 3
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'NouveauMotDePasse123!');
    await tester.enterText(fields.at(1), 'NouveauMotDePasse123!');
    await tester.tap(find.text('Enregistrer le nouveau mot de passe'));
    await tester.pumpAndSettle();

    expect(find.text('Félicitations !'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(mockRepo.lastResetPassword, 'NouveauMotDePasse123!');
  });
}
