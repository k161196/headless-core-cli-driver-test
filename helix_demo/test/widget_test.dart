import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:helix_demo/main.dart';

void main() {
  testWidgets('add/remove drives the shared core', (WidgetTester tester) async {
    await tester.pumpWidget(const HelixDemoApp());

    expect(find.text('Total qty: 0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('Total qty: 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('Total qty: 0'), findsOneWidget);
  });
}
