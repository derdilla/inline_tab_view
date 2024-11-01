import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inline_tab_view/src/inline_tab_view_render_object.dart';

void main() {
  testWidgets('propagates semantics of selected widget', (tester) async {
    fail('TODO: test');
  });
  testWidgets('calls visitChildrenForSemantics only for visible children', (tester) async {
    final controller = TabController(length: 4, vsync: const TestVSync());
    final tabViewRenderObject = InlineTabViewRenderObject(controller);

    final child1 = RenderConstrainedBox(additionalConstraints: BoxConstraints.tight(Size(10, 10)));
    final child2 = RenderConstrainedBox(additionalConstraints: BoxConstraints.tight(Size(20, 20)));
    final child3 = RenderConstrainedBox(additionalConstraints: BoxConstraints.tight(Size(30, 20)));
    final child4 = RenderConstrainedBox(additionalConstraints: BoxConstraints.tight(Size(40, 20)));
    final child5 = RenderConstrainedBox(additionalConstraints: BoxConstraints.tight(Size(50, 20)));
    tabViewRenderObject.add(child1);
    tabViewRenderObject.add(child2);
    tabViewRenderObject.add(child3);
    tabViewRenderObject.add(child4);
    tabViewRenderObject.add(child5);
    tabViewRenderObject.layout(BoxConstraints(maxWidth: 100.0, maxHeight: 100.0));

    final visitedChildren = <RenderObject>[];
    tabViewRenderObject.visitChildrenForSemantics(visitedChildren.add);
    expect(visitedChildren, containsAll([child1]));
    expect(visitedChildren, hasLength(1));

    controller.offset = 0.5;
    tabViewRenderObject.layout(BoxConstraints(maxWidth: 100.0, maxHeight: 100.0));

    visitedChildren.clear();
    tabViewRenderObject.visitChildrenForSemantics(visitedChildren.add);
    expect(visitedChildren, containsAll([child1, child2]));
    expect(visitedChildren, hasLength(2));

    controller.animateTo(3, duration: Duration.zero);
    controller.offset = -0.5;
    tabViewRenderObject.layout(BoxConstraints(maxWidth: 100.0, maxHeight: 100.0));

    visitedChildren.clear();
    tabViewRenderObject.visitChildrenForSemantics(visitedChildren.add);
    expect(visitedChildren, containsAll([child3, child4,]));
    expect(visitedChildren, hasLength(2));
  });
  testWidgets('test hitTestability of children', (tester) async {
    fail('TODO: test');
  });
}
