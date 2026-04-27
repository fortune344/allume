/// Coupure programmée annoncée par la CEET (relayée par une ou plusieurs sources).
class PlannedOutage {
  final DateTime startsAt;
  final DateTime endsAt;
  final List<String> zoneNames;
  /// Nombre de sources qui ont confirmé cette annonce.
  final int sourceCount;
  /// Vrai si les sources se contredisent sur les heures.
  final bool hasConflicts;

  const PlannedOutage({
    required this.startsAt,
    required this.endsAt,
    required this.zoneNames,
    required this.sourceCount,
    this.hasConflicts = false,
  });

  Duration get duration => endsAt.difference(startsAt);
}
