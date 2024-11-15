import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:inline_tab_view/src/inline_tab_view_parent_data.dart';

/// A render object that displays a tab, animated its height, and allows
/// dragging to switch tabs.
///
/// Interacts with a [TabController] to update tab bars ẃith the current scroll
/// progress.
class InlineTabViewRenderObject extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, InlineTabViewParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, InlineTabViewParentData>
    implements HitTestTarget {
  /// Create a render object that displays a tab, animated its height, and
  /// allows dragging to switch tabs.
  ///
  /// The provided [controller] must be valid.
  InlineTabViewRenderObject(this._controller) {
    assert(controller.animation != null, 'The TabController provided to '
        '$runtimeType is no longer valid.');
    controller.animation!.addListener(markNeedsLayout);
  }

  @override
  void dispose() {
    controller.animation?.removeListener(markNeedsLayout);
    super.dispose();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! InlineTabViewParentData) {
      child.parentData = InlineTabViewParentData();
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

  RenderBox? _childByIndex(int index) {
    // TODO: cache primary child and create specialized getter
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
    if (controller.indexIsChanging) return;
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
    if (kDebugMode) debugHandleEvent(event, entry);

    if (event is PointerDownEvent) {
      _dragStartPos = event.position.dx;
    } else if (event is PointerUpEvent) { // TODO: consider pointer cancel event
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

      if (!controller.indexIsChanging) controller.offset = offset;
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
    final RenderBox? selectedTab = _childByIndex(_index);
    final RenderBox? nextTab = selectedTab != null ? childAfter(selectedTab) : null;
    final RenderBox? previousTab = selectedTab != null ? childBefore(selectedTab) : null;

    selectedTab?.layout(constraints, parentUsesSize: true);
    nextTab?.layout(constraints, parentUsesSize: true);
    previousTab?.layout(constraints, parentUsesSize: true);
    visitChildren((RenderObject child) {
      if (child == selectedTab || child == nextTab || child == previousTab) return;
      child.layout(constraints);
    });

    if (selectedTab == null) {
      size = constraints.smallest;
      assert(false, '');
      return;
    }

    RenderBox? scrollingToTab = (_exactIndex == _index)
        ? null : ((_exactIndex > _index)
        ? nextTab
        : previousTab);

    if (scrollingToTab != null) {
      final totalHeightDiff = scrollingToTab.size.height - selectedTab.size.height;
      double movePercent = controller.offset.abs();
      while (movePercent > 1.0 &&
          ((_exactIndex > _index)
              ? childAfter(scrollingToTab!)
              : childBefore(scrollingToTab!)) != null) {
        movePercent -= 1.0;
        scrollingToTab = (_exactIndex > _index) // TODO: replace this duplicated lambda
            ? childAfter(scrollingToTab)!
            : childBefore(scrollingToTab)!;
      }

      assert(movePercent >= 0.0 && movePercent <= 1.0, '$movePercent out of '
          'range. Expected 0-1');

      final newHeight = selectedTab.size.height + movePercent * totalHeightDiff;
      size = Size(constraints.maxWidth, newHeight);
    } else {
      size = Size(constraints.maxWidth, selectedTab.size.height);
    }

    markNeedsPaint();
  }

  /// The horizontal center of the primary child.
  double get _relativeCentralDrawPosition {
    final horizontalCenter = size.width / 2;
    final horizontalOffset = - controller.offset * size.width;
    return horizontalCenter + horizontalOffset;

  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // The selected child aligns widgets to the top and takes the entire width.
    // When switching between children the view gets offset by a percentage of
    // the constraints (the tabController offset conveniently is in [-1.0,1.0].

    final horizontalDrawPosition = offset.dx + _relativeCentralDrawPosition;
    //print('size.width: ${size.width}, horizontalCenter: $horizontalCenter, horizontalOffset: $horizontalOffset');
    //print('_index: $_index, offset: $offset');

    final primaryChild = _childByIndex(_index)!;
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
  Rect? describeSemanticsClip(RenderBox? child) {
    final idx = _childByIndex(_index)!;
    if (child == idx) {
      return null; // Same as paint clip
    }
    return const Rect.fromLTRB(-1, -1, -1, -1); // Drop semantics
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    final primaryChild = _childByIndex(_index)!;
    final nextChild = childAfter(primaryChild);
    final previousChild = childBefore(primaryChild);

    final primaryLeftBorder = _relativeCentralDrawPosition - (primaryChild.size.width / 2);
    final primaryRightBorder = _relativeCentralDrawPosition + (primaryChild.size.width / 2);

    if (primaryRightBorder > 0.0
        && primaryLeftBorder < size.width) visitor(primaryChild);
    if (nextChild != null
        && primaryRightBorder + size.width > 0.0
        && primaryLeftBorder + size.width < size.width) visitor(nextChild);
    if (previousChild != null
        && primaryRightBorder - size.width > 0.0
        && primaryLeftBorder - size.width < size.width) visitor(previousChild);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    final primaryChild = _childByIndex(_index)!;
    final nextChild = childAfter(primaryChild);
    final previousChild = childBefore(primaryChild);

    final bool primary = primaryChild.hitTest(result, position: Offset(
      position.dx - _relativeCentralDrawPosition + (primaryChild.size.width / 2),
      position.dy,
    ));
    final bool? next = nextChild?.hitTest(result, position: Offset(
      position.dx - _relativeCentralDrawPosition + (primaryChild.size.width / 2) + size.width,
      position.dy,
    ));
    final bool? previous = previousChild?.hitTest(result, position: Offset(
      position.dx - _relativeCentralDrawPosition + (primaryChild.size.width / 2) - size.width,
      position.dy,
    ));
    return primary || (next ?? false) || (previous ?? false);
  }

  @override
  bool hitTestSelf(Offset position) => size.contains(position);
}

// TODO: didChangeDependencies, didUpdateWidget

// TODO: abstract layouting logic used by performLayout, paint,
//       hitTestChildren, and visitChildrenForSemantics
