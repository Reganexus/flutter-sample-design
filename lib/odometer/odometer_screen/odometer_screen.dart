import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_application_1/odometer/odometer_feature/odometer_price_controller.dart';
import 'package:flutter_application_1/odometer/odometer_feature/text_odotomer.dart';

class OdometerTextScreen extends StatefulWidget {
  const OdometerTextScreen({super.key});

  @override
  State<OdometerTextScreen> createState() => _OdometerTextScreenState();
}

class _OdometerTextScreenState extends State<OdometerTextScreen>
    with SingleTickerProviderStateMixin {
  
  late final OdometerPriceController _priceController;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();

    // 1. Initialize our controller, passing 'this' as the vsync ticker provider
    _priceController = OdometerPriceController(
      vsync: this,
      baseColor: Colors.blueAccent,
      uptickColor: Colors.green,
      downtickColor: Colors.red,
    );

    // Set an initial starting price
    _priceController.handlePriceBroadcast(3854210.50);

    // 2. Simulation ticker (In production, replace this with your WebSocket / Event Stream listener)
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (!mounted) return;
      
      final random = math.Random();
      final delta = (random.nextDouble() - 0.48) * 4500;
      final newPrice = (_priceController.currentPrice + delta).clamp(1000000.0, 10000000.0);

      // Feed raw number into controller — it handles direction, colors, and timers automatically!
      _priceController.handlePriceBroadcast(newPrice);
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Odometer Clean Architecture')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Live Market Buy Price",
                style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              
              // ListenableBuilder listens to state changes in our controller efficiently
              ListenableBuilder(
                listenable: _priceController,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        "₱ ",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      TextOdometer(
                        value: _priceController.currentPrice,
                        decimalPlaces: 2,
                        activeTint: _priceController.activeTint,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                "Screen is 100% decoupled. All business rules, colors, and animations live in the controller.",
                style: TextStyle(fontSize: 13, color: Colors.black45),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}