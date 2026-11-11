
import 'dart:math' as math;

import 'package:flutter/material.dart';

enum WipePanelDirection {
  enterFromRight,
  exitToLeft,
}

class DiagonalWipePanel extends StatelessWidget {
  final Color color;
  final double progress;
  final WipePanelDirection direction;

  const DiagonalWipePanel({
    super.key,
    required this.color,
    required this.progress,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _DiagonalWipePainter(
          color: color,
          progress: progress.clamp(0.0, 1.0),
          direction: direction,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DiagonalWipePainter extends CustomPainter {
  final Color color;
  final double progress;
  final WipePanelDirection direction;

  const _DiagonalWipePainter({
    required this.color,
    required this.progress,
    required this.direction,
  });

  static const double angle = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Horizontal offset needed to create a 12-degree slant.
    final slant = math.tan(angle * math.pi / 180) * height;

    late final double start;
    late final double end;

    switch (direction) {
      case WipePanelDirection.enterFromRight:
        start = width;
        end = -slant;

      case WipePanelDirection.exitToLeft:
        start = -slant;
        end = -width - (2 * slant);
    }

    final left = start + (end - start) * progress;

    // A full-height parallelogram.
    // The extra slant width prevents gaps at the viewport edges.
    final path = Path()
      ..moveTo(left + slant, 0)
      ..lineTo(left + width + (2 * slant), 0)
      ..lineTo(left + width + slant, height)
      ..lineTo(left, height)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DiagonalWipePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.progress != progress ||
        oldDelegate.direction != direction;
  }
}
