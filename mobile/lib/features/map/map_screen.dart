import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/spacing.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/typography.dart';

/// Inversion des couleurs des tuiles OSM pour le dark mode.
/// Blanc → noir, noir → blanc, légère désaturation pour ne pas écraser les couleurs.
Widget _darkModeTileBuilder(
  BuildContext context,
  Widget tileWidget,
  TileImage tile,
) {
  return ColorFiltered(
    colorFilter: const ColorFilter.matrix(<double>[
      -0.85, -0.05, -0.05, 0, 255,
      -0.05, -0.85, -0.05, 0, 255,
      -0.05, -0.05, -0.85, 0, 255,
         0,     0,     0, 1,   0,
    ]),
    child: tileWidget,
  );
}

/// Écran carte centré sur Lomé.
///
/// V1 : tuiles OpenStreetMap brutes. Les polygones de zones colorés par état
/// (vert / rouge / ambre / gris) seront ajoutés en Phase 1B après import OSM.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  /// Centre approximatif de Lomé (place de l'Indépendance).
  static const _lomeCenter = LatLng(6.1725, 1.2314);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Carte de Lomé', style: AppTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, size: 22),
            tooltip: 'Recentrer',
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: _lomeCenter,
              initialZoom: 12.5,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'tg.allume.allume',
                tileProvider: NetworkTileProvider(),
                tileBuilder: isDark ? _darkModeTileBuilder : null,
              ),
            ],
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: _MapLegend(),
          ),
          Positioned(
            right: AppSpacing.sm,
            bottom: AppSpacing.sm + 80,
            child: _AttributionPill(
              text: '© OpenStreetMap',
              colors: colors,
              surface: theme.colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LegendItem(color: colors.ok, label: 'Courant'),
          _LegendItem(color: colors.off, label: 'Coupure'),
          _LegendItem(color: colors.warn, label: 'Prévue'),
          _LegendItem(color: colors.unknown, label: 'Inconnu'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.small.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _AttributionPill extends StatelessWidget {
  final String text;
  final AppStatusColors colors;
  final Color surface;
  const _AttributionPill({
    required this.text,
    required this.colors,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: colors.textMuted),
      ),
    );
  }
}
