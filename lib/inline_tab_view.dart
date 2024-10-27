import 'package:flutter/material.dart';
import 'package:inline_tab_view/src/inline_tab_view_widget.dart';

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
    child: InlineTabViewWidget(
      controller: controller,
      tabs: tabs,
    ),
  );
}

// TODO:
// - context controller / API
// - didChangeDependencies, didUpdateWidget