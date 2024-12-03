import 'package:flutter/material.dart';
import 'package:inline_tab_view/src/inline_tab_view_widget.dart';
import 'package:inline_tab_view/src/offscreen_focus_exclusion_builder.dart';

/// A height adjusting widget switcher that displays the widget which
/// corresponds to the currently selected tab.
///
/// If a [TabController] is not provided, then there must be a [DefaultTabController]
/// ancestor.
///
/// The tab controller's [TabController.length] must equal the length of the
/// [children] list and the length of the [TabBar.tabs] list.
class InlineTabView extends StatelessWidget {
  /// Create a height adjusting widget switcher that displays the widget which
  /// corresponds to the currently selected tab.
  const InlineTabView({
    super.key,
    required this.children,
    this.controller,
    this.clipBehavior = Clip.hardEdge,
  });

  /// This widget's selection and animation state.
  ///
  /// If [TabController] is not provided, then the value of [DefaultTabController.of]
  /// will be used.
  final TabController? controller;

  /// One widget per tab.
  ///
  /// Its length must match the length of the [TabBar.tabs]
  /// list, as well as the [controller]'s [TabController.length].
  final List<Widget> children;

  /// The content will be clipped (or not) according to this option.
  ///
  /// See the enum Clip for details of all possible options and their common use
  /// cases. Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final TabController? controller =
        this.controller ?? DefaultTabController.maybeOf(context);

    assert(
        controller != null,
        'No TabController for $runtimeType.\n'
        'When creating a $runtimeType, you must either provide an explicit '
        'TabController using the "controller" property, or you must ensure that there '
        'is a DefaultTabController above the $runtimeType.\n'
        'In this case, there was neither an explicit controller nor a default controller.');
    assert(
        controller!.animation != null,
        'The TabController provided to '
        '$runtimeType is no longer valid.');
    assert(
        children.length == controller!.length,
        'Child count of $runtimeType '
        'does not match the provided tab controllers.');

    return ClipRect(
      clipBehavior: clipBehavior,
      child: OffscreenFocusExclusionBuilder(
        controller: controller!,
        children: children,
        builder: (List<Widget> children) => InlineTabViewWidget(
          controller: controller,
          children: children,
        ),
      ),
    );
  }
}
