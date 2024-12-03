import 'package:flutter/material.dart';

/// Only allow focus of the visible widget and block focus during animation by
/// wrapping children in [ExcludeFocus].
class OffscreenFocusExclusionBuilder extends StatelessWidget {
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
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? _child) {
          if (controller.indexIsChanging)
            return ExcludeFocus(child: builder(children));
          return builder([
            for (int i = 0; i < children.length; i++)
              ExcludeFocus(
                excluding: i != controller.index,
                child: children[i],
              )
          ]);
        },
      );
}
