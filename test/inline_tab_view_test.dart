import 'dart:ui';

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

  testWidgets('selected widget is hit testable', (tester) async {
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

    expect(find.text('Tab 1').hitTestable(), findsOneWidget);
    expect(find.text('Tab 2').hitTestable(), findsNothing);
    expect(find.text('Tab 3').hitTestable(), findsNothing);
    expect(find.text('Tab 4').hitTestable(), findsNothing);
    expect(find.text('Tab 5').hitTestable(), findsNothing);

    controller.animateTo(3, duration: Duration.zero);
    await tester.pump();

    expect(find.text('Tab 1').hitTestable(), findsNothing);
    expect(find.text('Tab 2').hitTestable(), findsNothing);
    expect(find.text('Tab 3').hitTestable(), findsNothing);
    expect(find.text('Tab 4').hitTestable(), findsOneWidget);
    expect(find.text('Tab 5').hitTestable(), findsNothing);
  });
  testWidgets('children visible during drag are hit testable', (tester) async  {
    final controller = TabController(length: 5, vsync: const TestVSync());
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: InlineTabView(
        controller: controller,
        children: [
          for(int i = 1; i <= 5; i++)
            ColoredBox(
              key: Key('$i'),
              color: [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.purple][i-1],
              child: Text('Tab $i'),
            ),
        ],
      ),
    ));

    expect(find.text('Tab 1').hitTestable(), findsOneWidget);
    expect(find.text('Tab 2').hitTestable(), findsNothing);

    final center = await tester.getCenter(find.byType(InlineTabView));
    final leftEdge = await tester.getBottomLeft(find.byType(InlineTabView)).dx;

    await expectLater(
      find.byType(InlineTabView),
      matchesGoldenFile('pre-drag.png'),
    );

    // Start drag sli
    final gesture = await tester.startGesture(Offset(center.dx + 1.0, center.dy));
    await tester.pump();

    expect(find.byKey(Key('1')).hitTestable(), findsOneWidget);
    expect(find.byKey(Key('2')).hitTestable(), findsNothing);

    await gesture.moveTo(Offset(leftEdge, center.dy));
    await tester.pump();
    await expectLater(
      find.byType(InlineTabView),
      matchesGoldenFile('post-drag.png'),
    );

    expect(find.byKey(Key('1')).hitTestable(at: Alignment.topLeft), findsOneWidget);
    // expect(find.byKey(Key('2')).hitTestable(at: Alignment.centerLeft), findsOneWidget); FIXME
  });
  testWidgets('hidden children are never hit testable', (tester) async  {
    fail('TODO: test');
  });

  testWidgets('can jump multiple widgets', (tester) async  {
    fail('TODO: test');
  });
  testWidgets("drag during animation doesn't throw", (tester) async  {
    fail('TODO: test');
  });
}
