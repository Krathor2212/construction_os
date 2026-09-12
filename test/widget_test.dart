import 'package:flutter_test/flutter_test.dart';

import 'package:construction_os/app/app.dart';

void main() {
  testWidgets('SuGoRa app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SuGoRaApp());

    expect(find.text('SuGoRa Construction OS'), findsOneWidget);
    expect(find.text('Construction Control Center'), findsOneWidget);
  });
}
