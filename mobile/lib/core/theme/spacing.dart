/// Échelle d'espacement de l'app.
///
/// Multiples de 4. Toute valeur en dehors de cette échelle doit être justifiée.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

/// Rayons de coin standardisés.
/// Pas de cards trop arrondies — on est dans une app sérieuse, pas un jeu mobile.
abstract final class AppRadii {
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 12.0;
}
