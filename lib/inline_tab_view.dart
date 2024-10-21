import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

//export 'widget_based_inline_tab_view.dart';

class InlineTabView extends StatelessWidget {
  InlineTabView({super.key,
    required this.controller,
    required this.tabs
  }) : assert(tabs.length == controller.length),
       assert(controller.animation != null, 'invalid controller');

  final TabController controller;

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: _InlineTabView(
      controller: controller,
      tabs: tabs,
    ),
  );
}

class _InlineTabView extends MultiChildRenderObjectWidget {
  const _InlineTabView({
    required this.controller,
    required List<Widget> tabs,
  }) : super(children: tabs);

  final TabController controller;

  @override
  _InlineTabViewRenderObject createRenderObject(BuildContext context) =>
      _InlineTabViewRenderObject(controller);

  @override
  void updateRenderObject(BuildContext context, _InlineTabViewRenderObject renderObject) {
    renderObject.controller = controller;
  }
}

class _InlineTabViewRenderObjectParentData extends ContainerBoxParentData<RenderBox> {}

class _InlineTabViewRenderObject extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _InlineTabViewRenderObjectParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _InlineTabViewRenderObjectParentData>
    implements HitTestTarget {
  _InlineTabViewRenderObject(this._controller) {
    controller.animation!.addListener(markNeedsLayout);
  }

  @override
  void dispose() {
    controller.animation?.removeListener(markNeedsLayout);
    super.dispose();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _InlineTabViewRenderObjectParentData) {
      child.parentData = _InlineTabViewRenderObjectParentData();
    }
  }

  TabController _controller;

  /// Primary controller of index and drag state.
  TabController get controller => _controller;
  set controller(TabController controller) {
    if (controller != _controller) {
      _controller = controller;
      markNeedsLayout();
    }
  }

  int get _index => controller.index;

  double get _exactIndex => controller.index + controller.offset;

  RenderBox? childByIndex(int index) {
    //print('x: $x, childCount: $childCount');
    if (index < 0 || index >= childCount) return null;
    RenderBox? child = firstChild;
    int i = 0;

    while (child != null && i < index) {
      child = childAfter(child);
      i++;
    }

    return child;
  }

  void _attemptSnap() {
    final offset = controller.offset;
    if (offset.abs() > 0.2) {
      final newIndex = (_index + offset.sign).clamp(0, controller.length - 1);
      controller.animateTo(newIndex.round());
    } else {
      controller.offset = 0;
    }
  }

  /// Horizontal value where the drag started.
  double? _dragStartPos;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _dragStartPos = event.position.dx;
    } else if (event is PointerUpEvent) {
      _attemptSnap();
      _dragStartPos = null;
      markNeedsLayout();
    } else if (event is PointerMoveEvent) {
      final delta = event.position.dx - _dragStartPos!;
      double offset = delta / size.width;
      offset = - offset;
      assert(offset >= -1.0 && offset <= 1.0);

      // avoid oob scroll
      if (controller.index == 0 && offset < 0
        || controller.index == (controller.length - 1) && offset > 0) offset = 0;

      controller.offset = offset;
      markNeedsPaint();
    }
  }

  @override
  void debugAssertDoesMeetConstraints() {
    assert(size.isFinite, 'TODO: document');
    super.debugAssertDoesMeetConstraints();
  }

  @override
  void performLayout() {
    // Since these 2 take the whole width, no other children need to be considered.
    final RenderBox? selectedTab = childByIndex(_index);
    final RenderBox? nextTab = selectedTab != null ? childAfter(selectedTab) : null;
    final RenderBox? previousTab = selectedTab != null ? childBefore(selectedTab) : null;

    selectedTab?.layout(constraints, parentUsesSize: true);
    nextTab?.layout(constraints, parentUsesSize: true);
    previousTab?.layout(constraints, parentUsesSize: true);

    if (selectedTab == null) {
      size = constraints.smallest;
      assert(false, '');
      return;
    }

    final scrollingToTab = (_exactIndex == _index)
     ? null : ((_exactIndex > _index)
        ? nextTab
        : previousTab);

    if (scrollingToTab != null) {
      final totalHeightDiff = scrollingToTab.size.height - selectedTab.size.height;
      double movePercent = controller.offset.abs();
      assert(movePercent >= 0.0 && movePercent <= 1.0);

      print(movePercent);
      final newHeight = selectedTab.size.height + movePercent * totalHeightDiff;
      size = Size(constraints.maxWidth, newHeight);
    } else {
      size = Size(constraints.maxWidth, selectedTab.size.height);
    }

    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // The selected child aligns widgets to the top and takes the entire width.
    // When switching between children the view gets offset by a percentage of
    // the constraints (the tabController offset conveniently is in [-1.0,1.0].

    final horizontalCenter = size.width / 2;
    final horizontalOffset = - controller.offset * size.width;
    final horizontalDrawPosition = offset.dx + horizontalCenter + horizontalOffset;
    //print('size.width: ${size.width}, horizontalCenter: $horizontalCenter, horizontalOffset: $horizontalOffset');
    //print('_index: $_index, offset: $offset');

    final primaryChild = childByIndex(_index)!;
    context.paintChild(primaryChild, Offset(
      horizontalDrawPosition - primaryChild.size.width / 2,
      offset.dy,
    ));

    // Render child before and after, potentially oob to simplify scrolling
    final nextChild = childAfter(primaryChild);
    final previousChild = childBefore(primaryChild);
    if (nextChild != null) {
      context.paintChild(nextChild, Offset(
        horizontalDrawPosition + size.width - nextChild.size.width / 2,
        offset.dy,
      ));
    }
    if (previousChild != null) {
      context.paintChild(previousChild, Offset(
        horizontalDrawPosition - size.width - previousChild.size.width / 2,
        offset.dy,
      ));
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    // The entire widget should be responsive to drags.
    return true;
  }

}



// TODO:
// - context controller
// - didChangeDependencies, didUpdateWidget
// - semantics