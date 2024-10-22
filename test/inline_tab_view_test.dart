import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inline_tab_view/inline_tab_view.dart';

void main() {
  testWidgets('2 widgets build smoke test', (tester) async {
    final controller = TabController(length: 2, vsync: const TestVSync());
    addTearDown(controller.dispose);
    await tester.pumpWidget(InlineTabView(
      controller: controller,
      tabs: const [
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
      tabs: [
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
}
