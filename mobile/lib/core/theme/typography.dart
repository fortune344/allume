import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hiérarchie typographique d'Allumé.
///
/// Police principale : Inter — sans-serif moderne, lisible à toutes tailles.
/// Deux graisses uniquement (regular 400, medium 500). Pas de bold partout.
abstract final class AppTextStyles {
  /// Pour les statistiques et les chiffres : chiffres tabulaires (toutes les
  /// chiffres ont la même largeur, les colonnes restent alignées).
  static const _tabularFigures = [FontFeature.tabularFigures()];

  // ─── Display & titres ─────────────────────────────────
  /// Très grand chiffre / état principal (ex : "OK" / "Coupure").
  static TextStyle display = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.8,
    height: 1.1,
  );

  /// Titre d'écran ou de section principale.
  static TextStyle title = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.3,
    height: 1.2,
  );

  /// Titre de section secondaire.
  static TextStyle subtitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    height: 1.3,
  );

  // ─── Corps de texte ───────────────────────────────────
  static TextStyle body = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static TextStyle bodyMuted = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static TextStyle small = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Métadonnée discrète (date, source, label).
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.3,
  );

  // ─── Chiffres tabulaires ──────────────────────────────
  /// Pour les durées, heures, nombres de sources, etc.
  static TextStyle stat = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    fontFeatures: _tabularFigures,
    height: 1.2,
  );

  /// Pour les chiffres très visibles (durée principale).
  static TextStyle statLarge = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    fontFeatures: _tabularFigures,
    letterSpacing: -0.3,
    height: 1.1,
  );
}
