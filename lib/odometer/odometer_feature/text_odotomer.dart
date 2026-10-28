import 'package:flutter/material.dart';

class TextOdometer extends StatefulWidget {
  final double value;
  final int decimalPlaces;
  final Color? activeTint;
  final TextStyle? style;

  const TextOdometer({
    super.key,
    required this.value,
    this.decimalPlaces = 2,
    this.activeTint,
    this.style,
  });

  @override
  State<TextOdometer> createState() => _TextOdometerState();
}

class _TextOdometerState extends State<TextOdometer>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 520);
  static const Duration _staggerDelay = Duration(milliseconds: 30);

  late final AnimationController _controller;
  double _oldValue = 0.0;
  double _newValue = 0.0;
  bool _isRising = true;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _newValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    )..value = 1.0;
  }

  @override
  void didUpdateWidget(covariant TextOdometer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _newValue = widget.value;
      _isRising = _newValue >= _oldValue;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final oldStr = _oldValue.toStringAsFixed(widget.decimalPlaces);
    final newStr = _newValue.toStringAsFixed(widget.decimalPlaces);

    int firstChangedIndex = newStr.length;
    for (int i = 0; i < newStr.length; i++) {
      if (i >= oldStr.length || oldStr[i] != newStr[i]) {
        firstChangedIndex = i;
        break;
      }
    }

    final defaultStyle = DefaultTextStyle.of(context).style;
    final textStyle = defaultStyle.merge(widget.style);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final baseProgress = CurvedAnimation(
          parent: _controller,
          curve: const Cubic(0.25, 0.8, 0.25, 1),
        ).value;

        List<Widget> digitWidgets = [];
        int changedDigitCount = 0;

        for (int i = 0; i < newStr.length; i++) {
          String char = newStr[i];
          bool isNumeric = char.contains(RegExp(r'[0-9]'));
          bool isAffected = i >= firstChangedIndex && isNumeric;

          if (isAffected) {
            int oldDigit = int.tryParse(i < oldStr.length ? oldStr[i] : '0') ?? 0;
            int newDigit = int.tryParse(newStr[i]) ?? 0;

            if (oldDigit == newDigit && _oldValue != _newValue) {
              newDigit = _isRising ? (oldDigit + 10) : (oldDigit - 10);
            } else if (_isRising && newDigit <= oldDigit) {
              newDigit += 10;
            } else if (!_isRising && newDigit >= oldDigit) {
              newDigit -= 10;
            }

            double staggerOffset = (changedDigitCount * _staggerDelay.inMilliseconds) / _duration.inMilliseconds;
            changedDigitCount++;
            double adjustedProgress = ((baseProgress - staggerOffset) / (1.0 - staggerOffset)).clamp(0.0, 1.0);

            List<int> reelDigits = [];
            int start = oldDigit;
            int end = newDigit;
            int step = end >= start ? 1 : -1;

            for (int current = start; step > 0 ? current <= end : current >= end; current += step) {
              int normalized = current % 10;
              if (normalized < 0) normalized += 10;
              reelDigits.add(normalized);
            }

            double fontSize = textStyle.fontSize ?? 16;
            double itemHeight = fontSize * 1.3;
            Color baseColor = textStyle.color ?? Colors.black87;
            Color activeColor = widget.activeTint ?? baseColor;

            double totalScrollOffset = adjustedProgress * (reelDigits.length - 1) * itemHeight;

            digitWidgets.add(
              SizedBox(
                height: itemHeight,
                width: fontSize * 0.60,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: itemHeight * (reelDigits.length + 2),
                    child: Transform.translate(
                      offset: Offset(0, -totalScrollOffset),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: reelDigits.map((d) {
                          return SizedBox(
                            height: itemHeight,
                            child: Center(
                              child: Text(
                                '$d',
                                style: textStyle.copyWith(
                                  height: 1.0,
                                  color: widget.activeTint != null ? activeColor : baseColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            digitWidgets.add(
              Text(
                char,
                style: textStyle.copyWith(height: 1.0),
              ),
            );
          }
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: digitWidgets,
        );
      },
    );
  }
}