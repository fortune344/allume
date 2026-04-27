import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:allume/app.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  testWidgets('L\'écran d\'accueil affiche le nom de l\'app et la zone utilisateur',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AllumeApp());
    await tester.pump();

    expect(find.text('Allumé'), findsOneWidget);
    expect(find.text('Tokoin'), findsOneWidget);
    expect(find.text('Le courant est là'), findsOneWidget);
  });
}
