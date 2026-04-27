import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

/// Construction des thèmes clair et sombre d'Allumé.
class AppTheme {
  static ThemeData light() {
    return _build(
      brightness: Brightness.light,
      bg: AppColors.lightBg,
      surface: AppColors.lightSurface,
      surfaceAlt: AppColors.lightSurfaceAlt,
      border: AppColors.lightBorder,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      textMuted: AppColors.lightTextMuted,
      statusOk: AppColors.statusOk,
      statusOff: AppColors.statusOff,
      statusWarn: AppColors.statusWarn,
      statusUnknown: AppColors.statusUnknown,
    );
  }

  static ThemeData dark() {
    return _build(
      brightness: Brightness.dark,
      bg: AppColors.darkBg,
      surface: AppColors.darkSurface,
      surfaceAlt: AppColors.darkSurfaceAlt,
      border: AppColors.darkBorder,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      textMuted: AppColors.darkTextMuted,
      statusOk: AppColors.statusOkDark,
      statusOff: AppColors.statusOffDark,
      statusWarn: AppColors.statusWarnDark,
      statusUnknown: AppColors.statusUnknownDark,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surfaceAlt,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
    required Color statusOk,
    required Color statusOff,
    required Color statusWarn,
    required Color statusUnknown,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.togoGold,
      onPrimary: isDark ? AppColors.darkBg : Colors.white,
      secondary: statusOk,
      onSecondary: Colors.white,
      error: statusOff,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceAlt,
      outline: border,
    );

    final textTheme = TextTheme(
      displayLarge: AppTextStyles.display.copyWith(color: textPrimary),
      titleLarge: AppTextStyles.title.copyWith(color: textPrimary),
      titleMedium: AppTextStyles.subtitle.copyWith(color: textPrimary),
      bodyLarge: AppTextStyles.body.copyWith(color: textPrimary),
      bodyMedium: AppTextStyles.body.copyWith(color: textSecondary),
      bodySmall: AppTextStyles.small.copyWith(color: textMuted),
      labelSmall: AppTextStyles.caption.copyWith(color: textMuted),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      textTheme: textTheme,
      dividerColor: border,
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.title.copyWith(color: textPrimary),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: border),
        ),
      ),
      extensions: [
        AppStatusColors(
          ok: statusOk,
          off: statusOff,
          warn: statusWarn,
          unknown: statusUnknown,
          surfaceAlt: surfaceAlt,
          border: border,
          textSecondary: textSecondary,
          textMuted: textMuted,
        ),
      ],
    );
  }
}

/// Couleurs fonctionnelles accessibles depuis n'importe quel widget via
/// `Theme.of(context).extension<AppStatusColors>()!`.
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  final Color ok;
  final Color off;
  final Color warn;
  final Color unknown;
  final Color surfaceAlt;
  final Color border;
  final Color textSecondary;
  final Color textMuted;

  const AppStatusColors({
    required this.ok,
    required this.off,
    required this.warn,
    required this.unknown,
    required this.surfaceAlt,
    required this.border,
    required this.textSecondary,
    required this.textMuted,
  });

  @override
  AppStatusColors copyWith({
    Color? ok,
    Color? off,
    Color? warn,
    Color? unknown,
    Color? surfaceAlt,
    Color? border,
    Color? textSecondary,
    Color? textMuted,
  }) =>
      AppStatusColors(
        ok: ok ?? this.ok,
        off: off ?? this.off,
        warn: warn ?? this.warn,
        unknown: unknown ?? this.unknown,
        surfaceAlt: surfaceAlt ?? this.surfaceAlt,
        border: border ?? this.border,
        textSecondary: textSecondary ?? this.textSecondary,
        textMuted: textMuted ?? this.textMuted,
      );

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      ok: Color.lerp(ok, other.ok, t)!,
      off: Color.lerp(off, other.off, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      unknown: Color.lerp(unknown, other.unknown, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}

extension AppThemeContextX on BuildContext {
  AppStatusColors get appColors =>
      Theme.of(this).extension<AppStatusColors>()!;
}
