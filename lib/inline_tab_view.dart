library inline_tab_view;

import 'package:flutter/material.dart';
import 'package:inline_tab_view/first_child_constrained.dart';

class InlineTabBarView extends StatelessWidget {
  const InlineTabBarView({super.key,
    required this.tabs,
    required this.controller,
  });

  final List<Widget> tabs;

  final TabController controller;

  /*
  @override
  Widget build(BuildContext context) => GestureDetector(
    onHorizontalDragStart: (details) {
      controller.offset = 0.0;
    },
    onHorizontalDragUpdate: (details) {
      // FIXME
      controller.offset = details.delta.dx / 2;
      print(controller.offset);
    },
    onHorizontalDragEnd: (details) {
      if (details.localPosition.dx > 0) {
        controller.offset = 1.0;
        controller.index++;
      } else {
        controller.offset = -1.0;
        controller.index--;
      }
    },
    onHorizontalDragCancel: () {},
    child: ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        //print(controller.animation?.value);
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 200,
          ),
          child: Stack(
            children: [
              AnimatedSize(
                duration: controller.animationDuration,
                child: tabs[controller.index],
              ),
              AnimatedBuilder(
                animation: controller.animation!,
                builder: (BuildContext context, Widget? child) => Transform.translate(
                  //duration: controller.animationDuration,
                  //translation: Offset(2 * (controller.offset - 1), 0),
                  offset: Offset(-MediaQuery.of(context).size.width * controller.animation!.value, 0),
                  child: OverflowBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final t in tabs)
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Center(child: t),
                          ),
                        /*if (controller.index - 1 >= 0)
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Center(child: tabs[controller.index - 1]),
                          ),
                        AnimatedSize(
                          duration: controller.animationDuration,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Center(child: tabs[controller.index]),
                          ),
                        ),
                        if (controller.index + 1 < controller.length)
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Center(child: tabs[controller.index + 1]),
                          ),*/
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

   */

  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      return FirstChildConstrainedWidget(
        sizeDeterminingChild: AnimatedSize(
          duration: controller.animationDuration,
          child: tabs[controller.index],
        ),
        clippedChild: AnimatedBuilder(
          animation: controller.animation!,
          builder: (BuildContext context, Widget? child) => Transform.translate(
            //duration: controller.animationDuration,
            //translation: Offset(2 * (controller.offset - 1), 0),
            offset: Offset(-MediaQuery.of(context).size.width * controller.animation!.value, 0),
            child: OverflowBox(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final t in tabs)
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: t),
                    ),
                  /*if (controller.index - 1 >= 0)
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Center(child: tabs[controller.index - 1]),
                            ),
                          AnimatedSize(
                            duration: controller.animationDuration,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Center(child: tabs[controller.index]),
                            ),
                          ),
                          if (controller.index + 1 < controller.length)
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Center(child: tabs[controller.index + 1]),
                            ),*/
                ],
              ),
            ),
          ),
        ),
      );
    }
  );
}
//FIXME: readd animated size
