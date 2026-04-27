import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'services/battery_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  // Démarre l'écoute des événements batterie. Non bloquant pour l'UI.
  unawaited(BatteryService.instance.initialize());
  runApp(const AllumeApp());
}
