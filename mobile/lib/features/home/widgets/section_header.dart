import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/typography.dart';

/// Titre de section sobre, avec une éventuelle action en complément à droite.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.caption.copyWith(color: colors.textMuted),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing!,
              style: AppTextStyles.caption.copyWith(color: colors.textMuted),
            ),
        ],
      ),
    );
  }
}
