/// État du courant pour une zone.
enum PowerStatus {
  /// Le courant est disponible.
  ok,
  /// Coupure en cours.
  off,
  /// Coupure programmée à venir.
  upcoming,
  /// Pas de données fiables pour cette zone.
  unknown,
}

/// État du courant dans une zone à un instant donné.
class ZoneStatus {
  final String zoneName;
  final PowerStatus status;
  /// Date à laquelle ce statut a commencé. Null si inconnu.
  final DateTime? since;
  /// Nombre de signaux qui ont contribué à ce statut. 0 = officiel uniquement.
  final int signalCount;

  const ZoneStatus({
    required this.zoneName,
    required this.status,
    this.since,
    this.signalCount = 0,
  });
}
