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
  Widget build(BuildContext context) => _InlineTabView(
    controller: controller,
    tabs: tabs,
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
    // renderObject.controller = controller
    // TODO
  }
}

class _InlineTabViewRenderObjectParentData extends ContainerBoxParentData<RenderBox> {}

class _InlineTabViewRenderObject extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _InlineTabViewRenderObjectParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _InlineTabViewRenderObjectParentData>
    implements HitTestTarget {
  _InlineTabViewRenderObject(this.controller) {
    __animationValue = controller.animation!.value;
    controller.animation!.addListener(_onTabControllerAnimationUpdate);
    // TODO: unregister when appropriate
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _InlineTabViewRenderObjectParentData) {
      child.parentData = _InlineTabViewRenderObjectParentData();
    }
  }

  void _onTabControllerAnimationUpdate() {
    __animationValue = controller.animation!.value;
    markNeedsLayout();
    markNeedsPaint();
  }

  final TabController controller;

  late double __animationValue;
  /// Local animation value kept in sync with the controllers.
  double get _animationValue => __animationValue;
  set _animationValue(double value) {
    print(value);
    __animationValue = value;
    controller.offset = value;
  }

  int get _index => controller.index;

  double get _exactIndex => controller.index + _animationValue;

  /// The [_index] that's most likely to be selected next in the current gesture.
  int? get _scrollingToIndex {
    if (_exactIndex > _index) return _index + 1;
    if (_exactIndex < _index) return _index - 1;
    return null;
  }

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
    final offset = _animationValue;
    _animationValue = 0.0;

    if (offset.abs() > 0.2) {
      final newIndex = (_index + offset.sign).clamp(0, controller.length - 1);
      controller.animateTo(newIndex.round());
    }
    // FIXME: back dragging unreliable
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
      // TODO: avoid oob scroll
      final delta = event.position.dx - _dragStartPos!;
      final offset = delta / size.width;
      assert(offset >= -1.0 && offset <= 1.0);

      _animationValue = - offset;
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
    final RenderBox? selectedTabSize = childByIndex(_index);
    final nextIndex = _scrollingToIndex; // TODO: optimize: use childAfter, cache back scrolling
    final RenderBox? nextTabSize = nextIndex != null ? childByIndex(nextIndex) : null;

    selectedTabSize?.layout(constraints, parentUsesSize: true);
    nextTabSize?.layout(constraints, parentUsesSize: true);

    if (selectedTabSize == null) {
      size = constraints.smallest;
      assert(false, '');
      return;
    }

    if (nextTabSize != null) {
      final totalHeightDiff = nextTabSize.size.height - selectedTabSize.size.height;
      final newHeight = selectedTabSize.size.height + _animationValue * totalHeightDiff;
      size = Size(constraints.maxWidth, newHeight);
    } else {
      size = Size(constraints.maxWidth, selectedTabSize.size.height);
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

    if (_exactIndex > _index && _index + 1 < controller.length ) {
      final child = childByIndex(_index + 1)!;
      context.paintChild(child, Offset(
        horizontalDrawPosition + size.width - child.size.width / 2,
        offset.dy,
      ));

    } else if (_exactIndex < _index && _index - 1 >= 0) {
      final child = childByIndex(_index - 1)!;
      context.paintChild(child, Offset(
        horizontalDrawPosition - size.width - child.size.width / 2,
        offset.dy,
      ));
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    // TODO: implement
    return true;
  }

}



// TODO:
// - dragging
// - context controller
// - didChangeDependencies, didUpdateWidget
// - semantics