library inline_tab_view;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:inline_tab_view/first_child_constrained.dart';
import 'dart:math' as math;

import 'animation_animated_size.dart';

class InlineTabBarView extends StatefulWidget {
  const InlineTabBarView({super.key,
    required this.tabs,
    required this.controller,
  });

  final List<Widget> tabs;

  final TabController controller;

  @override
  State<InlineTabBarView> createState() => _InlineTabBarViewState();
}

class _InlineTabBarViewState extends State<InlineTabBarView> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
      keepScrollOffset: false,
      onAttach: _onScrollableAttach,
      onDetach: _onScrollableDetach,
    );

    //widget.controller.
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScrollableAttach(ScrollPosition scrollPosition) {
    print('scrollPosition att: $scrollPosition');
  }

  void _onScrollableDetach(ScrollPosition scrollPosition) {
    print('scrollPosition det: $scrollPosition');
  }

  double _lastExtend = 0;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.depth != 0) return false;

          if (notification.metrics.atEdge) return true;
          if ((notification.metrics.extentAfter - _lastExtend) > 2) { // TODO: consider removing conditions if not needed
            // content to the left is visible
            widget.controller.offset = notification.metrics.pixels / notification.metrics.maxScrollExtent;
            _lastExtend = notification.metrics.extentAfter;
          } else if ((notification.metrics.extentAfter - _lastExtend) < -2) {
            // content to the right is visible
            widget.controller.offset = notification.metrics.pixels / notification.metrics.maxScrollExtent;
            _lastExtend = notification.metrics.extentAfter;
          }

          /*if (notification is ScrollEndNotification) {
            if (widget.controller.offset < 0.0) {
              widget.controller.index -= 1;
              widget.controller.offset = 0.0;
            } else if (widget.controller.offset > 0.0) {
              widget.controller.index += 1;
              widget.controller.offset = 0.0;
            }
          }*/ // FIXME: snapping
          return true;
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          dragStartBehavior: DragStartBehavior.down,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * widget.tabs.length,
            child: FirstChildConstrainedWidget(
              sizeDeterminingChild: AnimationAnimatedSize(
                controller: widget.controller,
                child: ListenableBuilder(
                  listenable: widget.controller.animation!,
                  builder: (_, __) => widget.tabs[widget.controller.index + widget.controller.offset.sign.toInt()],
                ),
              ),
              clippedChild: AnimatedBuilder(
                animation: widget.controller.animation!,
                builder: (BuildContext context, Widget? child) => OverflowBox(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final t in widget.tabs)
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Center(child: t),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  );
}
//FIXME: readd animated size
