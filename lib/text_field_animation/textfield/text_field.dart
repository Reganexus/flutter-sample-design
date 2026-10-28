import 'package:flutter/material.dart';

class CryptoBuyTextField extends StatelessWidget {
  final String rawAmount;
  final bool isInsufficient;
  final bool isAdding;
  final bool hasFocus;
  final FocusNode focusNode;
  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;

  const CryptoBuyTextField({
    super.key,
    required this.rawAmount,
    required this.isInsufficient,
    required this.isAdding,
    required this.hasFocus,
    required this.focusNode,
    required this.textController,
    required this.onChanged,
    required this.onTap,
  });

  String get _formattedAmount {
    if (rawAmount.isEmpty || rawAmount == "0") return "0";
    Parts parts = _splitDecimal(rawAmount);
    String wholeFormatted = _formatIntegerPart(parts.integer);
    return parts.hasDecimal ? "$wholeFormatted.${parts.decimal}" : wholeFormatted;
  }

  Parts _splitDecimal(String val) {
    if (val.contains('.')) {
      List<String> split = val.split('.');
      return Parts(integer: split[0], decimal: split.length > 1 ? split[1] : "", hasDecimal: true);
    }
    return Parts(integer: val, decimal: "", hasDecimal: false);
  }

  String _formatIntegerPart(String intStr) {
    if (intStr.isEmpty) return "0";
    if (intStr == "0") return "0";
    String cleanInt = intStr.startsWith('0') && intStr.length > 1 ? intStr.replaceFirst(RegExp(r'^0+'), '') : intStr;
    if (cleanInt.isEmpty) cleanInt = "0";

    final rev = cleanInt.split('').reversed.join();
    final buffer = StringBuffer();
    for (int i = 0; i < rev.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(rev[i]);
    }
    return buffer.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    String displayStr = _formattedAmount;
    bool isPlaceholder = rawAmount == "0" || rawAmount.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Offstage(
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: onChanged,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: isInsufficient ? Colors.redAccent : Colors.black26,
                  width: 2.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  "₱",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...List.generate(displayStr.length, (index) {
                          String char = displayStr[index];
                          bool isLastChar = (index == displayStr.length - 1);
                          
                          Color textColor;
                          if (isInsufficient) {
                            textColor = Colors.redAccent;
                          } else if (isPlaceholder) {
                            textColor = Colors.black87.withValues(alpha: 0.8);
                          } else {
                            textColor = Colors.black87;
                          }

                          if (isLastChar && !isPlaceholder && isAdding) {
                            return AnimatedDigitWidget(
                              key: ValueKey("anim_${displayStr.length}_$char"),
                              character: char,
                              textColor: textColor,
                            );
                          }

                          return Padding(
                            key: ValueKey("char_${index}_$char"),
                            padding: const EdgeInsets.symmetric(horizontal: 1.0),
                            child: Text(
                              char,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          );
                        }),
                        if (hasFocus)
                          BlinkingCaret(
                            caretColor: isInsufficient ? Colors.redAccent : Colors.green,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Parts {
  final String integer;
  final String decimal;
  final bool hasDecimal;
  Parts({required this.integer, required this.decimal, required this.hasDecimal});
}

class AnimatedDigitWidget extends StatefulWidget {
  final String character;
  final Color textColor;
  const AnimatedDigitWidget({
    super.key,
    required this.character,
    required this.textColor,
  });

  @override
  State<AnimatedDigitWidget> createState() => _AnimatedDigitWidgetState();
}

class _AnimatedDigitWidgetState extends State<AnimatedDigitWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  late final Animation<double> _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: Text(
          widget.character,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: widget.textColor,
          ),
        ),
      ),
    );
  }
}

class BlinkingCaret extends StatefulWidget {
  final Color caretColor;
  const BlinkingCaret({super.key, required this.caretColor});

  @override
  State<BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<BlinkingCaret> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        margin: const EdgeInsets.only(left: 2, top: 4),
        width: 3,
        height: 36,
        color: widget.caretColor,
      ),
    );
  }
}