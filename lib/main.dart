import 'package:flutter/material.dart';
import 'package:flutter_application_1/odometer/odometer_screen/odometer_screen.dart';
import 'package:flutter_application_1/splash/splash_screen.dart';
import 'package:flutter_application_1/tab_feature/tab_screen/tab_screen.dart';
import 'package:flutter_application_1/text_field_animation/crypto_buy_screen.dart';
import 'package:flutter_application_1/wipe/screen/order_transition_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initializeApp() async {
    // Fake initialization for testing. Replace with real startup work later.
    await Future.delayed(const Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: FlutterSplashScreen(
        initialize: _initializeApp,
        homeBuilder: (context) => const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDAX Animation Sandbox')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Button 1: Custom System Tab Screen
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CustomSystemTabScreen(),
                    ),
                  );
                },
                child: const Text('Go to Custom System Tab Screen'),
              ),
              const SizedBox(height: 16),

              // Button 2: Custom Text Form Screen
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CryptoBuyTestScreen(),
                    ),
                  );
                },
                child: const Text('Go to Custom Text Form Screen'),
              ),
              const SizedBox(height: 16),

              // Button 3: Custom Text Effect
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OdometerTextScreen(),
                    ),
                  );
                },
                child: const Text('Go to Custom Text Effect'),
              ),
              const SizedBox(height: 16),

              // Button 4: Custom Wipe Screen
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OrderTransitionDemo(),
                    ),
                  );
                },
                child: const Text('Go to Custom Wipe Screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}