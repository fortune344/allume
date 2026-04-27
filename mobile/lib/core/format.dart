import 'package:intl/intl.dart';

/// Formattages français cohérents pour toute l'app.
abstract final class AppFormat {
  /// "1h 47min", "32min", "5h", "2j 4h" — ergonomique pour les durées vécues.
  static String relativeDuration(Duration d) {
    if (d.inMinutes < 1) return 'à l\'instant';
    if (d.inMinutes < 60) return '${d.inMinutes}min';
    if (d.inHours < 24) {
      final minutes = d.inMinutes % 60;
      if (minutes == 0) return '${d.inHours}h';
      return '${d.inHours}h ${minutes.toString().padLeft(2, '0')}';
    }
    final hours = d.inHours % 24;
    if (hours == 0) return '${d.inDays}j';
    return '${d.inDays}j ${hours}h';
  }

  /// "depuis 14h32" — heure d'horloge en format français.
  static String timeOfDay(DateTime dt) {
    return DateFormat('HH\'h\'mm', 'fr_FR').format(dt);
  }

  /// "9h00 → 14h00", plage horaire courte.
  static String timeRange(DateTime start, DateTime end) {
    return '${timeOfDay(start)} → ${timeOfDay(end)}';
  }

  /// "Demain", "Vendredi 28", "12 mai" — date relative ergonomique.
  static String relativeDate(DateTime dt, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Demain';
    if (diff > 1 && diff < 7) {
      return DateFormat('EEEE d', 'fr_FR').format(dt);
    }
    return DateFormat('d MMMM', 'fr_FR').format(dt);
  }
}
