import 'package:flutter/material.dart';

import '../../core/theme/spacing.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/typography.dart';
import '../../shared/models/demo_data.dart';
import '../../shared/models/zone_status.dart';
import 'widgets/main_status_card.dart';
import 'widgets/manual_signal_button.dart';
import 'widgets/planned_outage_card.dart';
import 'widgets/section_header.dart';
import 'widgets/zone_row.dart';

/// Écran d'accueil d'Allumé.
///
/// Densité maîtrisée : ce que l'utilisateur cherche se voit en haut sans scroll.
/// Le reste est utile mais secondaire.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
  }

  void _handleManualSignal(PowerStatus status) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          status == PowerStatus.off
              ? 'Retour du courant signalé. Merci.'
              : 'Coupure signalée. Merci.',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final user = DemoData.userZone(now: _now);
    final nearby = DemoData.nearbyZones(now: _now);
    final upcoming = DemoData.upcomingOutages(now: _now);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: Row(
          children: [
            Container(
              width: 8,
              height: 24,
              decoration: BoxDecoration(
                color: colors.warn,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('Allumé', style: AppTextStyles.title),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 22),
            tooltip: 'Réglages',
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxxl,
          ),
          children: [
            MainStatusCard(zone: user, now: _now),
            const SizedBox(height: AppSpacing.lg),
            ManualSignalButton(
              currentStatus: user.status,
              onPressed: () => _handleManualSignal(user.status),
            ),
            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: 'À proximité'),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < nearby.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: ZoneRow(zone: nearby[i], now: _now),
                    ),
                    if (i < nearby.length - 1)
                      Divider(height: 1, color: colors.border),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            SectionHeader(
              title: 'Coupures programmées',
              trailing: '${upcoming.length} à venir',
            ),
            for (final outage in upcoming) ...[
              PlannedOutageCard(outage: outage, now: _now),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
