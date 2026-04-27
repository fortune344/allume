import 'package:flutter/material.dart';

/// Palette de couleurs d'Allumé.
///
/// Principe : couleurs fonctionnelles avant tout (statut du courant).
/// Les couleurs d'accent (or togolais, vert profond) restent rares
/// et signifiantes. Pas de couleur décorative gratuite.
abstract final class AppColors {
  // ─── Fonds ────────────────────────────────────────────
  /// Fond chaud, pas blanc pur — moins fatigant en plein soleil de Lomé.
  static const lightBg = Color(0xFFFAFAF7);
  /// Noir chaud, pas pur — pour la lecture de nuit pendant les coupures.
  static const darkBg = Color(0xFF0E0E0C);

  static const lightSurface = Color(0xFFFFFFFF);
  static const darkSurface = Color(0xFF1A1A18);

  static const lightSurfaceAlt = Color(0xFFF2F2EE);
  static const darkSurfaceAlt = Color(0xFF252522);

  static const lightBorder = Color(0xFFE5E5E0);
  static const darkBorder = Color(0xFF2D2D2A);

  // ─── Texte ────────────────────────────────────────────
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const darkTextPrimary = Color(0xFFF0F0EE);

  static const lightTextSecondary = Color(0xFF666666);
  static const darkTextSecondary = Color(0xFF9E9E9C);

  static const lightTextMuted = Color(0xFF999999);
  static const darkTextMuted = Color(0xFF6A6A68);

  // ─── Statuts (fonctionnel, le cœur de l'identité) ─────
  /// Vert profond — courant disponible. Pas un vert flashy.
  static const statusOk = Color(0xFF1A7F4F);
  static const statusOkDark = Color(0xFF2DA572);

  /// Rouge ferme — coupure. Pas un rouge clinquant.
  static const statusOff = Color(0xFFC73030);
  static const statusOffDark = Color(0xFFE85050);

  /// Ambre togolais — annonce / avertissement.
  static const statusWarn = Color(0xFFD49628);
  static const statusWarnDark = Color(0xFFE6B040);

  /// Gris neutre — pas d'information.
  static const statusUnknown = Color(0xFF8E8E8E);
  static const statusUnknownDark = Color(0xFF727270);

  // ─── Accents (rares, signifiants) ─────────────────────
  /// Or togolais — touches d'identité, jamais de fond.
  static const togoGold = Color(0xFFD4A332);
  /// Vert togolais profond — moments de marque (logo, splash).
  static const togoGreen = Color(0xFF005F2D);
}
