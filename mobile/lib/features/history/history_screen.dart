import 'package:flutter/material.dart';

import '../../core/theme/spacing.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/typography.dart';

/// Écran d'historique des coupures vécues et statistiques par zone.
/// V1 : structure visuelle, données réelles arrivent quand le backend sera connecté.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text('Historique', style: AppTextStyles.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: colors.border),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  size: 24,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Pas encore d\'historique',
                style: AppTextStyles.title.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ton historique de coupures et tes statistiques par quartier '
                'apparaîtront ici dès que tu auras vécu quelques coupures avec '
                'l\'app installée. Les données restent sur ton téléphone.',
                style: AppTextStyles.body.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
