import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';

/// État de charge tel qu'observé sur l'appareil.
enum DeviceChargeState {
  /// Branché et en charge (ou batterie pleine, branché).
  charging,
  /// Sur batterie, débranché.
  onBattery,
  /// État pas encore connu (au démarrage avant la première lecture).
  unknown,
}

/// Snapshot de l'état batterie à un instant donné.
@immutable
class BatterySnapshot {
  final DeviceChargeState state;
  final int? levelPercent;
  final DateTime updatedAt;

  const BatterySnapshot({
    required this.state,
    required this.levelPercent,
    required this.updatedAt,
  });
}

/// Service de surveillance de l'état batterie.
///
/// Expose un [ValueNotifier] qui notifie l'UI à chaque changement (branchement,
/// débranchement, niveau). Pas de polling actif : on s'abonne aux événements
/// OS (Android BroadcastReceiver via battery_plus).
class BatteryService extends ValueNotifier<BatterySnapshot> {
  BatteryService._() : super(_initialSnapshot());

  static BatterySnapshot _initialSnapshot() => BatterySnapshot(
        state: DeviceChargeState.unknown,
        levelPercent: null,
        updatedAt: DateTime.now(),
      );

  static final BatteryService instance = BatteryService._();

  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _subscription;
  Timer? _levelTimer;
  bool _initialized = false;

  /// À appeler une seule fois au démarrage de l'app.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _refreshSnapshot();

    _subscription = _battery.onBatteryStateChanged.listen((_) {
      _refreshSnapshot();
    });

    // Le niveau de batterie ne déclenche pas d'événement à chaque % perdu.
    // On le rafraîchit toutes les 2 minutes — coût négligeable.
    _levelTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _refreshSnapshot();
    });
  }

  Future<void> _refreshSnapshot() async {
    try {
      final state = await _battery.batteryState;
      final level = await _battery.batteryLevel;
      value = BatterySnapshot(
        state: _mapState(state),
        levelPercent: level,
        updatedAt: DateTime.now(),
      );
    } catch (_) {
      // Sur certains émulateurs ou ROMs custom, ces appels peuvent échouer.
      // On garde l'état précédent plutôt que de planter.
    }
  }

  static DeviceChargeState _mapState(BatteryState s) => switch (s) {
        BatteryState.charging => DeviceChargeState.charging,
        BatteryState.full => DeviceChargeState.charging,
        BatteryState.connectedNotCharging => DeviceChargeState.charging,
        BatteryState.discharging => DeviceChargeState.onBattery,
        BatteryState.unknown => DeviceChargeState.unknown,
      };

  @override
  void dispose() {
    _subscription?.cancel();
    _levelTimer?.cancel();
    super.dispose();
  }
}
