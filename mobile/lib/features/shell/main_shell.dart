import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/spacing.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/typography.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../map/map_screen.dart';

/// Coquille principale de l'app : trois onglets persistants.
/// IndexedStack préserve l'état de chaque onglet (utile quand la carte est chargée).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    MapScreen(),
    HistoryScreen(),
  ];

  static const _destinations = <_Destination>[
    _Destination(
      icon: Icons.bolt_outlined,
      activeIcon: Icons.bolt_rounded,
      label: 'Accueil',
    ),
    _Destination(
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: 'Carte',
    ),
    _Destination(
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
      label: 'Historique',
    ),
  ];

  void _onTap(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                for (var i = 0; i < _destinations.length; i++)
                  Expanded(
                    child: _NavButton(
                      destination: _destinations[i],
                      selected: i == _index,
                      onTap: () => _onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Destination {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Destination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavButton extends StatelessWidget {
  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final activeColor = theme.colorScheme.onSurface;
    final inactiveColor = colors.textMuted;
    final color = selected ? activeColor : inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? destination.activeIcon : destination.icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
