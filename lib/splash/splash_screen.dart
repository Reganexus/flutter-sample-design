import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class FlutterSplashScreen extends StatefulWidget {
  final Future<void> Function() initialize;
  final WidgetBuilder homeBuilder;

  const FlutterSplashScreen({
    super.key,
    required this.initialize,
    required this.homeBuilder,
  });

  @override
  State<FlutterSplashScreen> createState() => _FlutterSplashScreenState();
}

class _FlutterSplashScreenState extends State<FlutterSplashScreen>
    with SingleTickerProviderStateMixin {
  static const _nativeSplash = MethodChannel('native_splash');

  late final AnimationController _animationController;

  bool _nativeGone = false;
  bool _lottieLoaded = false;
  bool _loopStarted = false;

  bool _initializationCompleted = false;
  bool _isInitializing = false;
  bool _hasNavigated = false;

  Object? _initializationError;

  @override
  void initState() {
    super.initState();

    // Starts at value 0 (frame 0) and stays still until the native
    // overlay is gone. Duration is set once the Lottie file has loaded.
    _animationController = AnimationController(vsync: this);

    _nativeSplash.setMethodCallHandler((call) async {
      if (call.method == 'dismissed') _onNativeGone();
    });
    _checkNativeSplash();

    // _startInitialization();
  }

  Future<void> _checkNativeSplash() async {
    try {
      final dismissed = await _nativeSplash.invokeMethod<bool>('isDismissed');
      if (dismissed == true) _onNativeGone();
    } catch (_) {
      // No native side (iOS/tests): start right away.
      _onNativeGone();
    }
  }

  void _onNativeGone() {
    _nativeGone = true;
    _tryStartLoop();
  }

  void _tryStartLoop() {
    if (_loopStarted || !_nativeGone || !_lottieLoaded || !mounted) return;
    _loopStarted = true;
    _animationController.repeat();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    if (_isInitializing || _initializationCompleted) return;

    setState(() {
      _isInitializing = true;
      _initializationError = null;
    });

    try {
      await widget.initialize();

      if (!mounted) return;

      setState(() {
        _initializationCompleted = true;
        _isInitializing = false;
      });

      _checkCompletion();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _initializationError = error;
        _isInitializing = false;
      });
    }
  }

  void _checkCompletion() {
    if (_hasNavigated ||
        !_initializationCompleted ||
        _initializationError != null ||
        !_loopStarted) {
      return;
    }

    _hasNavigated = true;
    _animationController.stop();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return widget.homeBuilder(context);
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Lottie.asset(
              'assets/animations/loading_animation.json',
              controller: _animationController,
              fit: BoxFit.contain, // matches native FIT_CENTER
              onLoaded: (composition) {
                _animationController.duration = composition.duration;
                _lottieLoaded = true;
                _tryStartLoop();
              },
            ),
            if (_initializationError != null)
              Positioned(
                left: 24,
                right: 24,
                bottom: 40,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unable to initialize the application.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _isInitializing ? null : _startInitialization,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nativeSplash.setMethodCallHandler(null);
    _animationController.dispose();
    super.dispose();
  }
}