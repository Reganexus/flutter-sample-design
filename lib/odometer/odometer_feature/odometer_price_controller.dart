import 'dart:async';
import 'package:flutter/material.dart';

class OdometerPriceController extends ChangeNotifier {
  final TickerProvider vsync;
  
  // Define your app's standard market colors here once
  final Color baseColor;
  final Color uptickColor;
  final Color downtickColor;

  double _currentPrice = 0.0;
  double _previousPrice = 0.0;
  
  late final AnimationController _fadeController;
  late Animation<Color?> _colorAnimation;
  Timer? _holdTimer;

  double get currentPrice => _currentPrice;
  Color? get activeTint => _colorAnimation.value;

  OdometerPriceController({
    required this.vsync,
    this.baseColor = Colors.blueAccent,
    this.uptickColor = Colors.green,
    this.downtickColor = Colors.red,
  }) {
    _fadeController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 600),
    )..value = 1.0;

    _colorAnimation = ConstantTween<Color?>(baseColor).animate(_fadeController);
  }

  /// Feed raw numbers here; the controller figures out uptick/downtick and colors automatically
  void handlePriceBroadcast(double newPrice) {
    if (_currentPrice == 0.0) {
      _currentPrice = newPrice;
      _previousPrice = newPrice;
      notifyListeners();
      return;
    }

    if (newPrice == _currentPrice) return;

    _previousPrice = _currentPrice;
    _currentPrice = newPrice;

    // Automatically determine direction and select color
    final isRising = _currentPrice >= _previousPrice;
    final targetTint = isRising ? uptickColor : downtickColor;

    _holdTimer?.cancel();
    _fadeController.stop();

    // Create smooth transition back to base color
    _colorAnimation = ColorTween(
      begin: targetTint,
      end: baseColor,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.value = 0.0;
    notifyListeners();

    // Hold 700ms, then fade back to base color over 600ms
    _holdTimer = Timer(const Duration(milliseconds: 700), () {
      _fadeController.forward().then((_) {
        notifyListeners();
      });
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }
}