import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/typography.dart';
import '../../../services/battery_service.dart';

/// Ligne discrète au pied de la carte de statut principale.
///
/// Affiche ce que CET appareil détecte localement (état de charge pour l'instant ;
/// signaux Wi-Fi, son et lumière s'ajouteront aux phases suivantes).
class LocalSignalsRow extends StatelessWidget {
  const LocalSignalsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ValueListenableBuilder<BatterySnapshot>(
      valueListenable: BatteryService.instance,
      builder: (context, snapshot, _) {
        final (icon, label, color) = _signalFor(context, snapshot);
        return Row(
          children: [
            Container(height: 2, width: 16, color: colors.border),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Cet appareil',
              style: AppTextStyles.caption.copyWith(color: colors.textMuted),
            ),
            const Spacer(),
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  (IconData, String, Color) _signalFor(BuildContext ctx, BatterySnapshot s) {
    final colors = ctx.appColors;
    final pct = s.levelPercent;
    final pctSuffix = pct == null ? '' : ' · $pct%';
    return switch (s.state) {
      DeviceChargeState.charging => (
          Icons.bolt_rounded,
          'En charge$pctSuffix',
          colors.ok,
        ),
      DeviceChargeState.onBattery => (
          Icons.battery_5_bar_rounded,
          'Sur batterie$pctSuffix',
          colors.textSecondary,
        ),
      DeviceChargeState.unknown => (
          Icons.help_outline_rounded,
          'État inconnu',
          colors.textMuted,
        ),
    };
  }
}
