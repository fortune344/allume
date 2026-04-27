import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/zone_status.dart';

/// Bouton d'action principal : signaler une coupure ou son retour.
///
/// Le label change selon l'état actuel pour rester aligné avec le contexte.
/// L'action déclenche un retour haptique pour confirmer le tap.
class ManualSignalButton extends StatelessWidget {
  final PowerStatus currentStatus;
  final VoidCallback onPressed;

  const ManualSignalButton({
    super.key,
    required this.currentStatus,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isOff = currentStatus == PowerStatus.off;

    final label = isOff
        ? 'Signaler le retour du courant'
        : 'Signaler une coupure';
    final color = isOff ? colors.ok : colors.off;
    final icon = isOff ? Icons.bolt_rounded : Icons.power_off_rounded;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          child: Ink(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: Colors.white),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    label,
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
