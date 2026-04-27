import 'planned_outage.dart';
import 'zone_status.dart';

/// Données de démo pour développer l'UI sans backend.
///
/// Toutes les zones citées ici sont de vrais quartiers de Lomé.
/// Cette source de données sera remplacée par l'API en Phase 2.
class DemoData {
  /// Statut de la zone de l'utilisateur (par défaut Tokoin).
  static ZoneStatus userZone({DateTime? now}) {
    final t = now ?? DateTime.now();
    return ZoneStatus(
      zoneName: 'Tokoin',
      status: PowerStatus.ok,
      since: t.subtract(const Duration(hours: 1, minutes: 47)),
      signalCount: 4,
    );
  }

  /// Zones environnantes affichées sur l'accueil.
  static List<ZoneStatus> nearbyZones({DateTime? now}) {
    final t = now ?? DateTime.now();
    return [
      ZoneStatus(
        zoneName: 'Bè',
        status: PowerStatus.ok,
        since: t.subtract(const Duration(hours: 5, minutes: 12)),
        signalCount: 7,
      ),
      ZoneStatus(
        zoneName: 'Adidogomé',
        status: PowerStatus.off,
        since: t.subtract(const Duration(hours: 2, minutes: 5)),
        signalCount: 3,
      ),
      ZoneStatus(
        zoneName: 'Agoè',
        status: PowerStatus.ok,
        since: t.subtract(const Duration(hours: 3)),
        signalCount: 5,
      ),
      ZoneStatus(
        zoneName: 'Hédzranawoé',
        status: PowerStatus.upcoming,
        since: null,
        signalCount: 0,
      ),
      const ZoneStatus(
        zoneName: 'Cacaveli',
        status: PowerStatus.unknown,
      ),
    ];
  }

  /// Coupures programmées à venir.
  static List<PlannedOutage> upcomingOutages({DateTime? now}) {
    final t = now ?? DateTime.now();
    final tomorrow = DateTime(t.year, t.month, t.day + 1);
    final friday = DateTime(t.year, t.month, t.day + 3);
    return [
      PlannedOutage(
        startsAt: tomorrow.add(const Duration(hours: 9)),
        endsAt: tomorrow.add(const Duration(hours: 14)),
        zoneNames: const ['Hédzranawoé', 'Cacaveli'],
        sourceCount: 3,
      ),
      PlannedOutage(
        startsAt: friday.add(const Duration(hours: 8)),
        endsAt: friday.add(const Duration(hours: 15, minutes: 30)),
        zoneNames: const ['Bè', 'Bè-Kpota'],
        sourceCount: 2,
        hasConflicts: true,
      ),
    ];
  }
}
