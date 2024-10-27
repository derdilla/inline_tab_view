import 'package:flutter/material.dart';

import 'inline_tab_view_render_object.dart';

class InlineTabViewWidget extends MultiChildRenderObjectWidget {
  const InlineTabViewWidget({super.key,
    required this.controller,
    required List<Widget> tabs,
  }) : super(children: tabs);

  final TabController controller;

  @override
  InlineTabViewRenderObject createRenderObject(BuildContext context) =>
      InlineTabViewRenderObject(controller);

  @override
  void updateRenderObject(BuildContext context, InlineTabViewRenderObject renderObject) {
    renderObject.controller = controller;
  }
}