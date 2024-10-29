import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inline_tab_view/inline_tab_view.dart';

void main() {
  testWidgets('2 widgets build smoke test', (tester) async {
    final controller = TabController(length: 2, vsync: const TestVSync());
    addTearDown(controller.dispose);
    await tester.pumpWidget(InlineTabView(
      controller: controller,
      children: const [
        SizedBox(height: 100, width: 20),
        SizedBox(height: 200, width: 50),
      ],
    ));
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.byType(InlineTabView), findsOneWidget);
    expect(find.byType(SizedBox), findsNWidgets(2));
  });
  testWidgets('50 widgets build smoke test', (tester) async {
    final controller = TabController(length: 50, vsync: const TestVSync());
    addTearDown(controller.dispose);
    await tester.pumpWidget(InlineTabView(
      controller: controller,
      children: [
        for(int i = 1; i <= 50; i++)
          SizedBox(height: 10 + 4.0 * i, width: 50),
      ],
    ));
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.byType(InlineTabView), findsOneWidget);
    expect(find.byType(SizedBox), findsNWidgets(50));
  });
  testWidgets('shows selected widget', (tester) async {
    final controller = TabController(length: 5, vsync: const TestVSync());
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: InlineTabView(
        controller: controller,
        children: [
          for(int i = 1; i <= 5; i++)
            Text('Tab $i'),
        ],
      ),
    ));

    expect(find.text('Tab 1'), findsOneWidget);
    expect(find.text('Tab 2'), findsNothing);
    expect(find.text('Tab 3'), findsNothing);
    expect(find.text('Tab 4'), findsNothing);
    expect(find.text('Tab 5'), findsNothing);

    controller.animateTo(3);
    await tester.pumpAndSettle();
    expect(find.text('Tab 1'), findsNothing);
    expect(find.text('Tab 2'), findsNothing);
    expect(find.text('Tab 3'), findsNothing);
    expect(find.text('Tab 4'), findsOneWidget);
    expect(find.text('Tab 5'), findsNothing);
  });
  testWidgets('can jump multiple widgets', (tester) async  {
    fail('TODO: test');
  });
  testWidgets("drag during animation doesn't throw", (tester) async  {
    fail('TODO: test');
  });
}
