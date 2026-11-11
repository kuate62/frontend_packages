import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_packages/core/theme/app_theme.dart';
import 'package:frontend_packages/shared/widgets/app_button.dart';
import 'package:frontend_packages/shared/widgets/app_card.dart';
import 'package:frontend_packages/shared/widgets/app_status_badge.dart';
import 'package:frontend_packages/shared/widgets/app_text_field.dart';

void main() {
  testWidgets('les boutons gèrent chargement et désactivation', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              AppPrimaryButton(label: 'Valider', onPressed: () => count++),
              AppPrimaryButton(label: 'Chargement', onPressed: null, isLoading: true),
              AppOutlinedButton(label: 'Annuler', onPressed: null),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Valider'));
    await tester.pump();
    expect(count, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('les champs et badges se rendent', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Column(
            children: [
              AppTextField(label: 'Nom', controller: controller),
              AppPasswordField(label: 'Mot de passe'),
              AppStatusBadge(label: 'Livré', status: AppStatus.success),
              AppCard(child: const Text('Carte')),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'ExpressIO');
    expect(controller.text, 'ExpressIO');
    expect(find.text('Livré'), findsOneWidget);
    expect(find.text('Carte'), findsOneWidget);
  });
}