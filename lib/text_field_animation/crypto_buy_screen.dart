import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/text_field_animation/textfield/text_field.dart';
import 'dart:math' as math;

class CryptoBuyTestScreen extends StatefulWidget {
  const CryptoBuyTestScreen({super.key});

  @override
  State<CryptoBuyTestScreen> createState() => _CryptoBuyTestScreenState();
}

class _CryptoBuyTestScreenState extends State<CryptoBuyTestScreen>
    with TickerProviderStateMixin {
  String _rawAmount = "0";
  final double _phpBalance = 5000.0;
  final double _minBuy = 208.0;
  final int _maxDigits = 9;

  late final TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  late final AnimationController _buttonPressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
    lowerBound: 0.0,
    upperBound: 0.05,
  );

  bool _isInsufficient = false;
  bool _isBelowMin = false;
  bool _isAdding = false;
  bool _hasFocus = false;
  String _minTextState = "Min. ₱208";

  double get _numericAmount {
    return double.tryParse(_rawAmount.replaceAll(',', '')) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _rawAmount);
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _onTextChanged(String newText) {
    String cleanVal = newText.replaceAll(RegExp(r'[^0-9.]'), '');

    if (cleanVal.indexOf('.') != cleanVal.lastIndexOf('.')) {
      _triggerErrorFeedback();
      _updateTextFieldValue();
      return;
    }

    String digitsOnly = cleanVal.replaceAll('.', '');
    if (digitsOnly.length > _maxDigits) {
      _triggerErrorFeedback();
      _updateTextFieldValue();
      return;
    }

    if (cleanVal.contains('.')) {
      int decimalIndex = cleanVal.indexOf('.');
      if (cleanVal.length - decimalIndex > 3) {
        _triggerErrorFeedback();
        _updateTextFieldValue();
        return;
      }
    }

    setState(() {
      _isAdding = cleanVal.length > _rawAmount.length;
      _rawAmount = cleanVal.isEmpty ? "0" : cleanVal;
      _validateState();
    });
  }

  void _updateTextFieldValue() {
    _textController.text = _rawAmount;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );
  }

  void _triggerErrorFeedback() {
    HapticFeedback.lightImpact();
    _shakeController.forward(from: 0.0);
  }

  void _validateState() {
    double currentVal = _numericAmount;

    if (currentVal > _phpBalance) {
      if (!_isInsufficient) {
        HapticFeedback.heavyImpact();
        _shakeController.forward(from: 0.0);
      }
      setState(() {
        _isInsufficient = true;
        _minTextState = "Insufficient PHP balance";
      });
    } else {
      setState(() {
        _isInsufficient = false;
        _minTextState = "Min. ₱208";
      });
    }

    if (currentVal > 0 && currentVal < _minBuy) {
      setState(() {
        _isBelowMin = true;
      });
    } else {
      setState(() {
        _isBelowMin = false;
      });
    }
  }

  void _applyPercentage(double percentage) {
    HapticFeedback.selectionClick();
    double targetAmount = _phpBalance * percentage;
    setState(() {
      _isAdding = true;
      _rawAmount = targetAmount.toStringAsFixed(2);
      _updateTextFieldValue();
      _validateState();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    _buttonPressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        double sineVal = math.sin(_shakeController.value * math.pi * 4);
        double offsetX = _shakeController.isAnimating ? sineVal * 6.0 : 0.0;

        return GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_focusNode),
          child: Scaffold(
            appBar: AppBar(title: const Text('Crypto Buy Screen')),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Buy Bitcoin",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),

                    // Reusable Crypto Buy Text Field Widget with Shake Transform
                    Transform.translate(
                      offset: Offset(offsetX, 0),
                      child: CryptoBuyTextField(
                        rawAmount: _rawAmount,
                        isInsufficient: _isInsufficient,
                        isAdding: _isAdding,
                        hasFocus: _hasFocus,
                        focusNode: _focusNode,
                        textController: _textController,
                        onChanged: _onTextChanged,
                        onTap: () => FocusScope.of(context).requestFocus(_focusNode),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        _minTextState,
                        style: TextStyle(
                          fontSize: 14,
                          color: _isInsufficient || _isBelowMin
                              ? Colors.redAccent
                              : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Slider(
                      value: math.min(_numericAmount, _phpBalance),
                      min: 0,
                      max: _phpBalance,
                      activeColor: _isInsufficient ? Colors.redAccent : Colors.green,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (val) {
                        setState(() {
                          _isAdding = false;
                          _rawAmount = val.toStringAsFixed(2);
                          _updateTextFieldValue();
                          _validateState();
                        });
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPercentButton("25%", 0.25),
                        _buildPercentButton("50%", 0.50),
                        _buildPercentButton("75%", 0.75),
                        _buildPercentButton("Max", 1.00),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),

                    ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 0.95).animate(
                        CurvedAnimation(
                          parent: _buttonPressController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _isInsufficient || _numericAmount < _minBuy
                            ? null
                            : () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Listener(
                          onPointerDown: (_) => _buttonPressController.forward(),
                          onPointerUp: (_) => _buttonPressController.reverse(),
                          child: Text(
                            _isInsufficient ? "Insufficient Balance" : "Buy BTC",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isInsufficient ? Colors.black45 : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPercentButton(String label, double percentage) {
    return OutlinedButton(
      onPressed: () => _applyPercentage(percentage),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.black87)),
    );
  }
}