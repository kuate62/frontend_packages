import 'package:flutter/material.dart';

/// Palette centralisée d'ExpressIO.
///
/// Toute couleur doit être déclarée ici, jamais dans les widgets.
abstract final class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF0B5F8A);
  static const Color primaryLight = Color(0xFF3A86B3);
  static const Color primaryDark = Color(0xFF084666);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Couleurs secondaires
  static const Color secondary = Color(0xFFE07A2F);
  static const Color secondaryLight = Color(0xFFF0A36A);
  static const Color secondaryDark = Color(0xFFB85F1F);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Accentuation
  static const Color accent = Color(0xFF2BB6A0);
  static const Color accentLight = Color(0xFF6FD4C4);
  static const Color accentDark = Color(0xFF1F8F7D);

  // Fonds et surfaces (clair)
  static const Color background = Color(0xFFF4F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEAF0F4);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  // Textes (clair)
  static const Color textPrimary = Color(0xFF14202B);
  static const Color textSecondary = Color(0xFF5C6B78);
  static const Color textDisabled = Color(0xFF9AA7B3);

  // Bordures (clair)
  static const Color border = Color(0xFFD5DEE6);
  static const Color borderStrong = Color(0xFFB7C5D1);

  // Statuts (clair)
  static const Color success = Color(0xFF0E7A45);
  static const Color successSurface = Color(0xFFE7F3EC);
  static const Color warning = Color(0xFFB7791F);
  static const Color warningSurface = Color(0xFFF9F1E3);
  static const Color danger = Color(0xFFB42318);
  static const Color dangerSurface = Color(0xFFFDECEA);
  static const Color info = Color(0xFF1D6FB8);
  static const Color infoSurface = Color(0xFFE8F1FA);

  // Alias historiques
  static const Color seed = primary;
  static const Color accentLegacy = secondary;
  static const Color ink = textPrimary;
  static const Color inkMuted = textSecondary;
  static const Color line = border;
  static const Color dangerSurfaceLegacy = dangerSurface;

  // Mode sombre
  static const Color backgroundDark = Color(0xFF0F1720);
  static const Color surfaceDark = Color(0xFF17212B);
  static const Color surfaceVariantDark = Color(0xFF223040);
  static const Color surfaceCardDark = Color(0xFF1A2631);

  static const Color textPrimaryDark = Color(0xFFE7EEF3);
  static const Color textSecondaryDark = Color(0xFFA8B6C2);
  static const Color textDisabledDark = Color(0xFF6B7A88);

  static const Color borderDark = Color(0xFF2C3C49);
  static const Color borderStrongDark = Color(0xFF3D5061);

  static const Color successDark = Color(0xFF4ADE80);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color dangerDark = Color(0xFFFFB4AB);
  static const Color infoDark = Color(0xFF60A5FA);

  static const Color inkDark = textPrimaryDark;
  static const Color inkMutedDark = textSecondaryDark;
  static const Color lineDark = borderDark;
}
