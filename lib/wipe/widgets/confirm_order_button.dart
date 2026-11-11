
import 'package:flutter/material.dart';

class ConfirmOrderButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool disableAnimations;

  const ConfirmOrderButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.disableAnimations = false,
  });

  @override
  State<ConfirmOrderButton> createState() =>
      _ConfirmOrderButtonState();
}

class _ConfirmOrderButtonState extends State<ConfirmOrderButton> {
  bool _isPressed = false;

  Future<void> _handleTap() async {
    if (widget.isLoading || _isPressed) return;

    if (widget.disableAnimations) {
      widget.onPressed();
      return;
    }

    setState(() {
      _isPressed = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 120),
    );

    if (!mounted) return;

    setState(() {
      _isPressed = false;
    });

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed && !widget.disableAnimations
          ? 0.97
          : 1.0,
      duration: widget.disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 120),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: widget.isLoading ? null : _handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF39B402),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF39B402),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Confirm Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
