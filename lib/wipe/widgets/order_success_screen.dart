import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  final Animation<double> entrance;

  const OrderSuccessScreen({super.key, required this.entrance});

  double _progress(double value, double start, double end) {
    return Interval(start, end, curve: Curves.easeOut).transform(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: entrance,
          builder: (context, child) {
            final iconProgress = _progress(entrance.value, 0.0, 0.55);
            final titleProgress = _progress(entrance.value, 0.15, 0.70);
            final descriptionProgress = _progress(entrance.value, 0.30, 0.85);
            final buttonProgress = _progress(entrance.value, 0.45, 1.0);

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedElement(
                    progress: iconProgress,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE4F4DA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF39B402),
                        size: 64,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildAnimatedElement(
                    progress: titleProgress,
                    child: const Text(
                      'Order Successful!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildAnimatedElement(
                    progress: descriptionProgress,
                    child: const Text(
                      'Your order has been placed successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ),

                  const SizedBox(height: 48),

                  _buildAnimatedElement(
                    progress: buttonProgress,
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF39B402),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedElement({
    required double progress,
    required Widget child,
  }) {
    return Opacity(
      opacity: progress.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 16 * (1 - progress)),
        child: child,
      ),
    );
  }
}
