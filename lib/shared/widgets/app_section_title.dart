import 'package:flutter/material.dart';

import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

/// Titre de section réutilisable.
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.bodySmall?.color;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.subtitle),
              if (subtitle != null) ...[
                const SizedBox(height: AppDimensions.xxs),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(color: color),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
