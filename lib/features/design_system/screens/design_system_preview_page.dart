import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_view.dart';
import '../../../shared/widgets/app_error_view.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_section_title.dart';
import '../../../shared/widgets/app_status_badge.dart';
import '../../../shared/widgets/app_text_field.dart';

/// Écran temporaire de validation visuelle du Design System.
/// Réservé au développement, non exposé comme écran principal.
class DesignSystemPreviewPage extends StatelessWidget {
  const DesignSystemPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design System ExpressIO')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.md),
        children: [
          const AppSectionTitle(title: 'Couleurs'),
          Wrap(
            spacing: AppDimensions.xs,
            runSpacing: AppDimensions.xs,
            children: const [
              _ColorChip(label: 'Primaire', color: AppColors.primary),
              _ColorChip(label: 'Secondaire', color: AppColors.secondary),
              _ColorChip(label: 'Accent', color: AppColors.accent),
              _ColorChip(label: 'Succès', color: AppColors.success),
              _ColorChip(label: 'Avertissement', color: AppColors.warning),
              _ColorChip(label: 'Erreur', color: AppColors.danger),
              _ColorChip(label: 'Info', color: AppColors.info),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          const AppSectionTitle(title: 'Typographie'),
          const Text('Display', style: AppTextStyles.display),
          const Text('Headline', style: AppTextStyles.headline),
          const Text('Title', style: AppTextStyles.title),
          const Text('Subtitle', style: AppTextStyles.subtitle),
          const Text('Body', style: AppTextStyles.body),
          const Text('Body small', style: AppTextStyles.bodySmall),
          const Text('Label', style: AppTextStyles.label),
          const Text('Caption', style: AppTextStyles.caption),
          const SizedBox(height: AppDimensions.lg),
          const AppSectionTitle(title: 'Boutons'),
          AppPrimaryButton(label: 'Primaire', onPressed: () {}),
          const SizedBox(height: AppDimensions.xs),
          AppSecondaryButton(label: 'Secondaire', onPressed: () {}),
          const SizedBox(height: AppDimensions.xs),
          AppOutlinedButton(label: 'Contour', onPressed: () {}),
          const SizedBox(height: AppDimensions.xs),
          AppPrimaryButton(
            label: 'Chargement',
            onPressed: null,
            isLoading: true,
          ),
          const SizedBox(height: AppDimensions.lg),
          const AppSectionTitle(title: 'Champs'),
          AppTextField(label: 'Email', hintText: 'nom@exemple.com'),
          const SizedBox(height: AppDimensions.xs),
          AppPasswordField(label: 'Mot de passe'),
          const SizedBox(height: AppDimensions.xs),
          AppSearchField(hintText: 'Rechercher un colis'),
          const SizedBox(height: AppDimensions.lg),
          const AppSectionTitle(title: 'Carte'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expédition TRK-2026-000123',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: AppDimensions.xs),
                const Text('Statut actuel', style: AppTextStyles.bodySmall),
                const SizedBox(height: AppDimensions.xs),
                Wrap(
                  spacing: AppDimensions.xs,
                  children: const [
                    AppStatusBadge(label: 'En transit', status: AppStatus.info),
                    AppStatusBadge(label: 'Livré', status: AppStatus.success),
                    AppStatusBadge(label: 'Retard', status: AppStatus.warning),
                    AppStatusBadge(label: 'Incident', status: AppStatus.error),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          const AppSectionTitle(title: 'Chargement'),
          const AppLoadingIndicator(message: 'Chargement...'),
          const SizedBox(height: AppDimensions.lg),
          const AppSectionTitle(title: 'État vide'),
          const AppEmptyView(title: 'Aucun colis', message: 'Rien à afficher'),
          const SizedBox(height: AppDimensions.lg),
          const AppSectionTitle(title: 'Erreur'),
          AppErrorView(message: 'Échec réseau', onRetry: () {}),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimensions.radius),
          ),
        ),
        const SizedBox(height: AppDimensions.xxs),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
