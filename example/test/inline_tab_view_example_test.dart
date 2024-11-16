import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('builds all examples and documentation', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: InlineTabViewExample())));
    expect(find.text('These examples include a TabBar, the classical TabBarView'
    ' (constrained to a fixed height), and the InlineTabView.'), findsOneWidget);

    const exampleCount = 3;
    expect(find.textContaining('Example', skipOffstage: false), findsNWidgets(exampleCount));
    expect(find.byType(FormSwitcher, skipOffstage: false), findsNWidgets(exampleCount));
    expect(find.byType(Divider, skipOffstage: false), findsNWidgets(exampleCount));

    // 3 boxes from example 1 title and 20 boxes from example 3 title and content each.
    expect(find.textContaining('Box', skipOffstage: false), findsAtLeast(2 + 20));
  });
  testWidgets('classical toggle works', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: InlineTabViewExample())));
    expect(find.byType(TabBarView, skipOffstage: false), findsNothing);

    await tester.tap(find.text('Display classical TabBarView'));
    await tester.pumpAndSettle();

    expect(find.byType(TabBarView, skipOffstage: false), findsNWidgets(3));
  });
}
