import 'package:flutter/material.dart';

/// Only allow focus of the visible widget and block focus during animation by
/// wrapping children in [ExcludeFocus].
class OffscreenFocusExclusionBuilder extends StatefulWidget {
  /// Only allow focus of the visible widget and block focus during animation.
  const OffscreenFocusExclusionBuilder({
    super.key,
    required this.controller,
    required this.children,
    required this.builder,
  });

  /// This widget's selection and animation state.
  final TabController controller;

  /// One widget per tab.
  ///
  /// Its length must match the length of the [TabBar.tabs]
  /// list, as well as the [controller]'s [TabController.length].
  final List<Widget> children;

  /// Child builder, takes the wrapped children.
  final Widget Function(List<Widget> children) builder;

  @override
  State<OffscreenFocusExclusionBuilder> createState() => _OffscreenFocusExclusionBuilderState();
}

class _OffscreenFocusExclusionBuilderState extends State<OffscreenFocusExclusionBuilder> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(markNeedsRebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(markNeedsRebuild);
    super.dispose();
  }

  void markNeedsRebuild() => setState((){});
  
  @override
  Widget build(BuildContext context) {
    if (widget.controller.indexIsChanging) return ExcludeFocus(child: widget.builder(widget.children));
    return widget.builder([
      for (int i = 0; i < widget.children.length; i++)
        ExcludeFocus(
          excluding: i != widget.controller.index,
          child: widget.children[i],
        )
    ]);
  }
}
