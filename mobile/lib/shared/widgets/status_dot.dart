import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../models/zone_status.dart';

/// Petit point coloré indiquant l'état du courant.
/// Sobre, sans halo, sans animation décorative.
class StatusDot extends StatelessWidget {
  final PowerStatus status;
  final double size;

  const StatusDot({
    super.key,
    required this.status,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorFor(context, status),
        shape: BoxShape.circle,
      ),
    );
  }

  static Color colorFor(BuildContext context, PowerStatus status) {
    final c = context.appColors;
    return switch (status) {
      PowerStatus.ok => c.ok,
      PowerStatus.off => c.off,
      PowerStatus.upcoming => c.warn,
      PowerStatus.unknown => c.unknown,
    };
  }

  static String labelFor(PowerStatus status) => switch (status) {
        PowerStatus.ok => 'Courant OK',
        PowerStatus.off => 'Coupure',
        PowerStatus.upcoming => 'Coupure prévue',
        PowerStatus.unknown => 'Inconnu',
      };
}
