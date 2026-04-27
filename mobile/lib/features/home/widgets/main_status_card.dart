import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/zone_status.dart';
import '../../../shared/widgets/status_dot.dart';

/// La carte principale de l'écran d'accueil : état du courant chez l'utilisateur.
/// Grand, immédiat, lisible — ce que la maman cherche en ouvrant l'app.
class MainStatusCard extends StatelessWidget {
  final ZoneStatus zone;
  final DateTime now;

  const MainStatusCard({
    super.key,
    required this.zone,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final statusColor = StatusDot.colorFor(context, zone.status);

    final mainLabel = switch (zone.status) {
      PowerStatus.ok => 'Le courant est là',
      PowerStatus.off => 'Coupure en cours',
      PowerStatus.upcoming => 'Coupure à venir',
      PowerStatus.unknown => 'État inconnu',
    };

    final since = zone.since;
    final sinceLabel = since == null
        ? null
        : 'Stable depuis ${AppFormat.relativeDuration(now.difference(since))}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                zone.zoneName,
                style: AppTextStyles.title.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Ta zone',
                style: AppTextStyles.caption.copyWith(color: colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  mainLabel,
                  style: AppTextStyles.display.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (sinceLabel != null) ...[
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                sinceLabel,
                style: AppTextStyles.body.copyWith(color: colors.textSecondary),
              ),
            ),
          ],
          if (zone.signalCount > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  height: 2,
                  width: 16,
                  color: colors.border,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${zone.signalCount} appareil${zone.signalCount > 1 ? 's' : ''} confirme${zone.signalCount > 1 ? 'nt' : ''}',
                  style: AppTextStyles.caption.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
