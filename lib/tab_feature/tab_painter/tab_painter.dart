import 'package:flutter/material.dart';

class TopLinePainter extends CustomPainter {
  final double left;
  final double right;
  final Color color;
  TopLinePainter({
    required this.left,
    required this.right,
    required this.color,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    // Placed exactly along the top edge (0.0 -> 2.0)
    canvas.drawRect(Rect.fromLTRB(left, 0.0, right, 2.0), paint);
  }

  @override
  bool shouldRepaint(covariant TopLinePainter oldDelegate) {
    return oldDelegate.left != left || oldDelegate.right != right;
  }
}
