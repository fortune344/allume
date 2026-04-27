import 'package:flutter/material.dart';

import '../../../core/format.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/zone_status.dart';
import '../../../shared/widgets/status_dot.dart';

/// Ligne dense pour afficher l'état d'un quartier voisin.
class ZoneRow extends StatelessWidget {
  final ZoneStatus zone;
  final DateTime now;

  const ZoneRow({
    super.key,
    required this.zone,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final since = zone.since;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          StatusDot(status: zone.status, size: 8),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              zone.zoneName,
              style: AppTextStyles.body.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            StatusDot.labelFor(zone.status),
            style: AppTextStyles.small.copyWith(
              color: StatusDot.colorFor(context, zone.status),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          SizedBox(
            width: 56,
            child: Text(
              since == null ? '—' : AppFormat.relativeDuration(now.difference(since)),
              style: AppTextStyles.stat.copyWith(color: colors.textMuted),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
