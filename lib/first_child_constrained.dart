import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

enum _ChildHierarchySlot {
  sizeDeterminingChild,
  clippedChild,
}

/// A widget that sizes [clippedChild] to the size of another
/// [sizeDeterminingChild] widget.
class FirstChildConstrainedWidget
    extends SlottedMultiChildRenderObjectWidget<_ChildHierarchySlot, RenderBox> {
  /// Create a widget that sizes [clippedChild] to the size of another
  /// [sizeDeterminingChild] widget.
  const FirstChildConstrainedWidget({super.key,
    required this.sizeDeterminingChild,
    required this.clippedChild,
  });

  /// Widget specifying the height, doesn't get painted.
  ///
  /// When this is larger than [clippedChild] empty space stays, when this is
  /// smaller then the child is clipped.
  final Widget sizeDeterminingChild;

  /// Child that gets rendered to [sizeDeterminingChild]'s size.
  final Widget clippedChild;

  @override
  Iterable<_ChildHierarchySlot> get slots => _ChildHierarchySlot.values;

  @override
  Widget? childForSlot(_ChildHierarchySlot slot) => switch(slot) {
    _ChildHierarchySlot.sizeDeterminingChild => sizeDeterminingChild,
    _ChildHierarchySlot.clippedChild => clippedChild,
  };

  @override
  SlottedContainerRenderObjectMixin<_ChildHierarchySlot, RenderBox> createRenderObject(
    BuildContext context,
  ) => _FirstChildConstrainedRenderObject();
}

class _FirstChildConstrainedRenderObject extends RenderBox
    with SlottedContainerRenderObjectMixin<_ChildHierarchySlot, RenderBox>,
        DebugOverflowIndicatorMixin {

  // Getters to simplify accessing the slotted children.
  RenderBox? get _clippedChild => childForSlot(_ChildHierarchySlot.clippedChild);
  RenderBox? get _sizeDeterminingChild => childForSlot(_ChildHierarchySlot.sizeDeterminingChild);

  @override
  void performLayout() {
    // sizeDeterminingChild can be as big as this widget, clippedChild can be
    // as big as sizeDeterminingChild.
    final sizeDetermining = _sizeDeterminingChild;
    if (sizeDetermining != null) {
      sizeDetermining.layout(constraints, parentUsesSize: true);
      size = sizeDetermining.size;
    }

    final newConstraints = BoxConstraints(
      maxWidth: size.width,
      maxHeight: size.height,
    );
    _clippedChild?.layout(newConstraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_clippedChild != null) {
      context.paintChild(_clippedChild!, offset);
    }

    if (kDebugMode) {
      paintOverflowIndicator(context, offset,
        Offset.zero & size,
        Offset.zero & (_sizeDeterminingChild?.size ?? Size.zero),
      );
    }
    // TODO: implement paint
  }

}

/*
class FirstChildConstrainedRenderObject extends RenderObject
    with ContainerRenderObjectMixin<RenderBox, InlineTabViewParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, InlineTabViewParentData> {
  FirstChildConstrainedRenderObject({});

  final RenderBox sizeDeterminingChild;
  final RenderBox clippedChild;

  @override
  void debugAssertDoesMeetConstraints() {
    // TODO: implement debugAssertDoesMeetConstraints
  }

  @override
  Rect get paintBounds => sizeDeterminingChild.paintBounds;

  @override
  void performLayout() {
    sizeDeterminingChild.layout(constraints, parentUsesSize: true);
    final newConstraints = BoxConstraints(
      maxWidth: sizeDeterminingChild.size.width,
      maxHeight: sizeDeterminingChild.size.height,
    );

    clippedChild.layout(newConstraints);
  }

  @override
  void performResize() {
    // TODO: implement performResize
  }

  @override
  // TODO: implement semanticBounds
  Rect get semanticBounds => sizeDeterminingChild.semanticBounds;

}*/

class InlineTabViewParentData extends ContainerBoxParentData<RenderBox> {}
