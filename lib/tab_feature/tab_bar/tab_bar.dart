import 'package:flutter/material.dart';
import 'package:flutter_application_1/tab_feature/tab_painter/tab_painter.dart';

class CustomStretchTabBar extends StatefulWidget {
  final TabController controller;
  final List<String> tabs;
  final ValueChanged<int> onTabTap;
  final bool reduceMotion;

  const CustomStretchTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    required this.onTabTap,
    required this.reduceMotion,
  });

  @override
  State<CustomStretchTabBar> createState() => _CustomStretchTabBarState();
}

class _CustomStretchTabBarState extends State<CustomStretchTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _indicatorAnimController;
  double _startX = 0.0;
  double _targetX = 0.0;
  int _lastIndex = 0;

  final List<IconData> _icons = [
    Icons.home_filled,
    Icons.explore,
    Icons.settings,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _indicatorAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    widget.controller.addListener(_handleTabChange);
    _lastIndex = widget.controller.index;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabChange);
    _indicatorAnimController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!mounted) return;
    final int targetIndex = widget.controller.index;
    if (targetIndex == _lastIndex) return;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double tabWidth = screenWidth / widget.tabs.length;
    const double indicatorWidth = 28.0;
    final double centerOffset = (tabWidth - indicatorWidth) / 2;

    final double currentStartX = _lastIndex * tabWidth + centerOffset;
    final double currentTargetX = targetIndex * tabWidth + centerOffset;

    final int distance = (targetIndex - _lastIndex).abs();

    // High-speed compensation for multi-tab leaps to maintain visible elastic delays
    int targetMillis = widget.reduceMotion ? 120 : 720;
    if (distance > 1 && !widget.reduceMotion) {
      targetMillis = 720 + (distance - 1) * 45;
    }

    setState(() {
      _startX = currentStartX;
      _targetX = currentTargetX;
      _lastIndex = targetIndex;
    });

    _indicatorAnimController.duration = Duration(milliseconds: targetMillis);
    _indicatorAnimController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double tabWidth = screenWidth / widget.tabs.length;
    const double indicatorWidth = 28.0;
    final double centerOffset = (tabWidth - indicatorWidth) / 2;

    if (_startX == 0.0 && _targetX == 0.0) {
      _startX = widget.controller.index * tabWidth + centerOffset;
      _targetX = _startX;
    }

    return Stack(
      children: [
        // 1. INDICATOR: 2px green line, 28px wide, pinned precisely to the top edge
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 2.0,
          child: AnimatedBuilder(
            animation: _indicatorAnimController,
            builder: (context, child) {
              final double progress = _indicatorAnimController.value;
              double leftEdge = _startX;
              double rightEdge = _startX + indicatorWidth;

              if (widget.reduceMotion) {
                // Reduced Motion fallback: Linear slide without scaling/stretching
                leftEdge = _startX + (_targetX - _startX) * progress;
                rightEdge = leftEdge + indicatorWidth;
              } else if (progress > 0.0 && progress < 1.0) {
                const Curve customBezier = Cubic(0.4, 0.0, 0.2, 1.0);

                // Peak stretch splits precisely at 50% progress
                final double leadingProgress = customBezier.transform(
                  (progress / 0.5).clamp(0.0, 1.0),
                );
                final double trailingProgress = customBezier.transform(
                  ((progress - 0.5) / 0.5).clamp(0.0, 1.0),
                );

                if (_targetX > _startX) {
                  leftEdge = _startX + (_targetX - _startX) * trailingProgress;
                  rightEdge =
                      (_startX + indicatorWidth) +
                      (_targetX - _startX) * leadingProgress;
                } else {
                  leftEdge = _startX - (_startX - _targetX) * leadingProgress;
                  rightEdge =
                      (_startX + indicatorWidth) -
                      (_startX - _targetX) * trailingProgress;
                }
              } else if (progress == 1.0) {
                leftEdge = _targetX;
                rightEdge = _targetX + indicatorWidth;
              }

              return CustomPaint(
                painter: TopLinePainter(
                  left: leftEdge,
                  right: rightEdge,
                  color: Colors.green,
                ),
              );
            },
          ),
        ),
        // 2. ICONS & LABELS: Color only transitions (gray <-> green), 150ms timing, zero scaling
        Row(
          children: List.generate(widget.tabs.length, (index) {
            return Expanded(
              child: InkWell(
                onTap: () => widget.onTabTap(index),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: AnimatedBuilder(
                  animation: widget.controller.animation!,
                  builder: (context, child) {
                    final double animationValue =
                        widget.controller.animation!.value;
                    // Compute absolute target proximity color bounds
                    final double selectionStrength = (animationValue - index)
                        .abs();
                    final double lerpFactor = (1.0 - selectionStrength).clamp(
                      0.0,
                      1.0,
                    );

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _icons[index],
                            color: Color.lerp(
                              Colors.grey,
                              Colors.green,
                              lerpFactor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.tabs[index],
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.lerp(
                                Colors.grey,
                                Colors.green,
                                lerpFactor,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
