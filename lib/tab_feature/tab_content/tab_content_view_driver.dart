import 'package:flutter/material.dart';

class TabContentViewDriver extends StatefulWidget {
  final ScrollController scrollController;
  final bool reduceMotion;
  const TabContentViewDriver({
    super.key,
    required this.scrollController,
    required this.reduceMotion,
  });
  @override
  State createState() => _TabContentViewDriverState();
}

class _TabContentViewDriverState extends State<TabContentViewDriver>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) {
      return ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: 20,
        itemBuilder: (context, index) => _buildCard(index),
      );
    }
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (context, index) {
        // Sections index capped at 8 merge matching guidelines
        final int staggerIndex = index < 8 ? index : 8;
        // Transitions begin at 108ms delay, with 60ms incremental steps
        final int startOffsetMillis = 108 + (staggerIndex * 60);
        final int endOffsetMillis = startOffsetMillis + 480;
        final double startInterval = (startOffsetMillis / 1200).clamp(0.0, 1.0);
        final double endInterval = (endOffsetMillis / 1200).clamp(0.0, 1.0);
        final Animation sectionAnimation = CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            startInterval,
            endInterval,
            curve: const Cubic(
              0.2,
              0.8,
              0.2,
              1.0,
            ), // cubic-bezier(.2, .8, .2, 1)
          ),
        );
        return AnimatedBuilder(
          animation: sectionAnimation,
          builder: (context, child) {
            final double progress = sectionAnimation.value;
            // Incoming content: fades up 8px over 480ms from the top down
            final double opacity = progress;
            final double yTranslation = (1.0 - progress) * 8.0;
            return Transform.translate(
              offset: Offset(0, yTranslation),
              child: Opacity(opacity: opacity, child: _buildCard(index)),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'Section Block ${index + 1}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
