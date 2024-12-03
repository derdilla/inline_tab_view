import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inline_tab_view/inline_tab_view.dart';
import 'package:inline_tab_view/src/offscreen_focus_exclusion_builder.dart';

void main() {
  testWidgets('hidden children are not focusable', (tester) async {
    final controller = TabController(length: 2, vsync: const TestVSync());
    addTearDown(controller.dispose);

    final leadingFocus = FocusNode();
    addTearDown(leadingFocus.dispose);
    final trailingFocus = FocusNode();
    addTearDown(trailingFocus.dispose);
    final tab1Wid1Focus = FocusNode();
    addTearDown(tab1Wid1Focus.dispose);
    final tab1Wid2Focus = FocusNode();
    addTearDown(tab1Wid2Focus.dispose);
    final tab1Wid3Focus = FocusNode();
    addTearDown(tab1Wid3Focus.dispose);
    final tab2Wid1Focus = FocusNode();
    addTearDown(tab2Wid1Focus.dispose);
    final tab2Wid2Focus = FocusNode();
    addTearDown(tab2Wid2Focus.dispose);
    final tab2Wid3Focus = FocusNode();
    addTearDown(tab2Wid3Focus.dispose);

    await tester.pumpWidget(MaterialApp(
      home: Column(
        children: [
          Focus(key: Key('leading'), focusNode: leadingFocus, child: SizedBox.square(dimension: 10)),
          InlineTabView(
            controller: controller,
            children: [
              Column(children: [
                Focus(key: Key('Tab 1 - 1'), focusNode: tab1Wid1Focus, child: SizedBox.square(dimension: 10)),
                Focus(key: Key('Tab 1 - 2'), focusNode: tab1Wid2Focus, child: SizedBox.square(dimension: 10)),
                Focus(key: Key('Tab 1 - 3'), focusNode: tab1Wid3Focus, child: SizedBox.square(dimension: 10)),
              ],),
              Column(children: [
                Focus(key: Key('Tab 2 - 1'), focusNode: tab2Wid1Focus, child: SizedBox.square(dimension: 10)),
                Focus(key: Key('Tab 2 - 2'), focusNode: tab2Wid2Focus, child: SizedBox.square(dimension: 10)),
                Focus(key: Key('Tab 2 - 3'), focusNode: tab2Wid3Focus, child: SizedBox.square(dimension: 10)),
              ],)
            ],
          ),
          Focus(key: Key('trailing'), focusNode: trailingFocus, child: SizedBox.square(dimension: 10)),
        ],
      ),
    ));
    expect(find.byType(OffscreenFocusExclusionBuilder), findsOneWidget);

    tab1Wid1Focus.requestFocus();
    await tester.pumpAndSettle();
    expect(leadingFocus.hasFocus, false);
    expect(tab1Wid1Focus.hasFocus, true);
    expect(tab1Wid2Focus.hasFocus, false);
    expect(tab1Wid3Focus.hasFocus, false);
    expect(tab2Wid1Focus.hasFocus, false);
    expect(tab2Wid2Focus.hasFocus, false);
    expect(tab2Wid3Focus.hasFocus, false);
    expect(trailingFocus.hasFocus, false);

    // it doesn't (shouldn't) matter which node is used to request the next focus.
    leadingFocus.nextFocus();
    await tester.pumpAndSettle();
    expect(leadingFocus.hasFocus, false);
    expect(tab1Wid1Focus.hasFocus, false);
    expect(tab1Wid2Focus.hasFocus, true);
    expect(tab1Wid3Focus.hasFocus, false);
    expect(tab2Wid1Focus.hasFocus, false);
    expect(tab2Wid2Focus.hasFocus, false);
    expect(tab2Wid3Focus.hasFocus, false);
    expect(trailingFocus.hasFocus, false);

    leadingFocus.nextFocus();
    await tester.pumpAndSettle();
    expect(leadingFocus.hasFocus, false);
    expect(tab1Wid1Focus.hasFocus, false);
    expect(tab1Wid2Focus.hasFocus, false);
    expect(tab1Wid3Focus.hasFocus, true);
    expect(tab2Wid1Focus.hasFocus, false);
    expect(tab2Wid2Focus.hasFocus, false);
    expect(tab2Wid3Focus.hasFocus, false);
    expect(trailingFocus.hasFocus, false);

    leadingFocus.nextFocus();
    await tester.pumpAndSettle();
    expect(leadingFocus.hasFocus, false);
    expect(tab1Wid1Focus.hasFocus, false);
    expect(tab1Wid2Focus.hasFocus, false);
    expect(tab1Wid3Focus.hasFocus, false);
    expect(tab2Wid1Focus.hasFocus, false);
    expect(tab2Wid2Focus.hasFocus, false);
    expect(tab2Wid3Focus.hasFocus, false);
    expect(trailingFocus.hasFocus, true);

    leadingFocus.previousFocus();
    leadingFocus.previousFocus();
    leadingFocus.previousFocus();
    leadingFocus.previousFocus();
    await tester.pumpAndSettle();
    expect(leadingFocus.hasFocus, true);
    expect(tab1Wid1Focus.hasFocus, false);
    expect(tab1Wid2Focus.hasFocus, false);
    expect(tab1Wid3Focus.hasFocus, false);
    expect(tab2Wid1Focus.hasFocus, false);
    expect(tab2Wid2Focus.hasFocus, false);
    expect(tab2Wid3Focus.hasFocus, false);
    expect(trailingFocus.hasFocus, false);
  });
}
