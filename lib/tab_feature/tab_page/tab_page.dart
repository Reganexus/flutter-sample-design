import 'package:flutter/material.dart';
import 'package:flutter_application_1/tab_feature/tab_content/tab_content_view_driver.dart';

class CustomTabPageView extends StatelessWidget {
  final TabController controller;
  final Map<int, ScrollController> scrollControllers;
  final bool reduceMotion;

  const CustomTabPageView({
    super.key,
    required this.controller,
    required this.scrollControllers,
    required this.reduceMotion,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: List.generate(controller.length, (index) {
            final bool isSelected = controller.index == index;
            return IgnorePointer(
              ignoring: !isSelected,
              child: AnimatedOpacity(
                // Outgoing page transitions: Fades out over 180ms ease-in
                opacity: isSelected ? 1.0 : 0.0,
                duration: Duration(milliseconds: reduceMotion ? 120 : 180),
                curve: Curves.easeIn,
                child: isSelected
                    ? TabContentViewDriver(
                        scrollController: scrollControllers[index]!,
                        reduceMotion: reduceMotion,
                      )
                    : const SizedBox.shrink(),
              ),
            );
          }),
        );
      },
    );
  }
}
