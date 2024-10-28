import 'package:flutter/material.dart';

import 'package:inline_tab_view/inline_tab_view.dart';
import 'package:inline_tab_view/src/inline_tab_view_render_object.dart';

/// A widget that uses the [InlineTabViewRenderObject].
///
/// Consider using [InlineTabView] instead.
class InlineTabViewWidget extends MultiChildRenderObjectWidget {
  /// Create a widget that uses the [InlineTabViewRenderObject].
  ///
  /// Consider using [InlineTabView] instead.
  InlineTabViewWidget({super.key,
    required this.controller,
    required super.children,
  }): assert(controller.animation != null, 'The TabController provided to '
      'InlineTabViewWidget is no longer valid.'),
    assert(children.length == controller.length, 'Child count of '
      'InlineTabViewWidget does not match the provided tab controllers.');

  /// A valid tab controller whose length matches [children]'s.
  final TabController controller;

  @override
  InlineTabViewRenderObject createRenderObject(BuildContext context) =>
    InlineTabViewRenderObject(controller);

  @override
  void updateRenderObject(BuildContext context, InlineTabViewRenderObject renderObject) {
    renderObject.controller = controller;
  }
}
