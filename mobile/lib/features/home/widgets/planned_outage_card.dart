import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/planned_outage.dart';

/// Carte d'une coupure programmée à venir.
/// Affiche transparence sur les sources et les conflits éventuels.
class PlannedOutageCard extends StatelessWidget {
  final PlannedOutage outage;
  final DateTime now;

  const PlannedOutageCard({
    super.key,
    required this.outage,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final dateLabel = AppFormat.relativeDate(outage.startsAt, now: now);
    final timeLabel = AppFormat.timeRange(outage.startsAt, outage.endsAt);
    final durationLabel = AppFormat.relativeDuration(outage.duration);

    final sourcesLabel = outage.hasConflicts
        ? '${outage.sourceCount} sources, durée incertaine'
        : '${outage.sourceCount} source${outage.sourceCount > 1 ? 's' : ''} concordante${outage.sourceCount > 1 ? 's' : ''}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.warn,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                dateLabel.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: colors.warn,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                durationLabel,
                style: AppTextStyles.stat.copyWith(color: colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            timeLabel,
            style: AppTextStyles.statLarge.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            outage.zoneNames.join(' · '),
            style: AppTextStyles.body.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                outage.hasConflicts ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 14,
                color: outage.hasConflicts ? colors.warn : colors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                sourcesLabel,
                style: AppTextStyles.small.copyWith(color: colors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
