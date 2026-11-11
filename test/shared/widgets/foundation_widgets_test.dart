import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_packages/core/theme/app_theme.dart';
import 'package:frontend_packages/shared/widgets/app_button.dart';
import 'package:frontend_packages/shared/widgets/app_empty_view.dart';
import 'package:frontend_packages/shared/widgets/app_error_view.dart';
import 'package:frontend_packages/shared/widgets/app_loading_indicator.dart';
import 'package:frontend_packages/shared/widgets/app_text_field.dart';

void main() {
  testWidgets('les composants de base réagissent au toucher et à la saisie', (
    tester,
  ) async {
    var pressed = 0;
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                AppButton(label: 'Continuer', onPressed: () => pressed++),
                AppTextField(label: 'Téléphone', controller: controller),
                const AppLoadingIndicator(message: 'Chargement'),
                const AppEmptyView(
                  title: 'Aucun colis',
                  message: 'Rien à afficher',
                ),
                AppErrorView(message: 'Échec réseau', onRetry: () => pressed++),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Continuer'));
    await tester.enterText(find.byType(TextField), '0700000000');
    await tester.tap(find.widgetWithText(FilledButton, 'Réessayer'));
    await tester.pump();

    expect(pressed, 2);
    expect(controller.text, '0700000000');
    expect(find.text('Chargement'), findsOneWidget);
    expect(find.text('Aucun colis'), findsOneWidget);
    expect(find.text('Échec réseau'), findsOneWidget);
  });
}
