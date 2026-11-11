import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

enum AppStatus { success, warning, error, info, neutral }

/// Badge de statut coloré.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.status = AppStatus.neutral,
  });

  final String label;
  final AppStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors(
      status,
      Theme.of(context).brightness,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _colors(AppStatus status, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return switch (status) {
      AppStatus.success => (
        isDark
            ? AppColors.successDark.withValues(alpha: 0.2)
            : AppColors.successSurface,
        isDark ? AppColors.successDark : AppColors.success,
      ),
      AppStatus.warning => (
        isDark
            ? AppColors.warningDark.withValues(alpha: 0.2)
            : AppColors.warningSurface,
        isDark ? AppColors.warningDark : AppColors.warning,
      ),
      AppStatus.error => (
        isDark
            ? AppColors.dangerDark.withValues(alpha: 0.2)
            : AppColors.dangerSurface,
        isDark ? AppColors.dangerDark : AppColors.danger,
      ),
      AppStatus.info => (
        isDark
            ? AppColors.infoDark.withValues(alpha: 0.2)
            : AppColors.infoSurface,
        isDark ? AppColors.infoDark : AppColors.info,
      ),
      AppStatus.neutral => (
        isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
    };
  }
}
