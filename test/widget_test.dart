import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:construction_os/app/app.dart';

void main() {
  testWidgets('SuGoRa app loads', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SuGoRaApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SuGoRaApp), findsOneWidget);
  });
}