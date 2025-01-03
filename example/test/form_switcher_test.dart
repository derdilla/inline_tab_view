import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inline_tab_view/inline_tab_view.dart';

void main() {
  testWidgets('shows a InlineTabView', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: FormSwitcher(
      displayClassical: false,
      subforms: [
        (SizedBox(width: 1, height: 1), SizedBox(width: 2, height: 2))
      ],
    ))));

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(TabBarView), findsNothing);
    expect(find.byType(InlineTabView), findsOneWidget);
  });
  testWidgets('respects displayClassical', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: FormSwitcher(
      displayClassical: true,
      subforms: [
        (SizedBox(width: 1, height: 1), SizedBox(width: 2, height: 2))
      ],
    ))));

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.byType(InlineTabView), findsOneWidget);
  });
  testWidgets('shows all passed tabs in TabBar', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: FormSwitcher(
      displayClassical: false,
      subforms: [
        (Text('Tab 1'), SizedBox(width: 2, height: 2)),
        (Text('Tab 2'), SizedBox(width: 2, height: 2)),
        (Text('Tab 3'), SizedBox(width: 2, height: 2)),
        (Text('Tab 4'), SizedBox(width: 2, height: 2)),
      ],
    ))));

    expect(find.text('Tab 1'), findsOneWidget);
    expect(find.text('Tab 2'), findsOneWidget);
    expect(find.text('Tab 3'), findsOneWidget);
    expect(find.text('Tab 4'), findsOneWidget);
  });
  testWidgets('associates title and widget correctly', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: FormSwitcher(
      displayClassical: false,
      subforms: [
        (Text('Tab 1'), Text('Content 1')),
        (Text('Tab 2'), Text('Content 2')),
        (Text('Tab 3'), Text('Content 3')),
        (Text('Tab 4'), Text('Content 4')),
      ],
    ))));

    expect(find.text('Content 1'), findsOneWidget);
    expect(find.text('Content 2'), findsNothing);
    expect(find.text('Content 3'), findsNothing);
    expect(find.text('Content 4'), findsNothing);

    await tester.tap(find.text('Tab 2'));
    await tester.pumpAndSettle();

    expect(find.text('Content 1'), findsNothing);
    expect(find.text('Content 2'), findsOneWidget);
    expect(find.text('Content 3'), findsNothing);
    expect(find.text('Content 4'), findsNothing);

    await tester.tap(find.text('Tab 4'));
    await tester.pumpAndSettle();

    expect(find.text('Content 1'), findsNothing);
    expect(find.text('Content 2'), findsNothing);
    expect(find.text('Content 3'), findsNothing);
    expect(find.text('Content 4'), findsOneWidget);
  });
}
