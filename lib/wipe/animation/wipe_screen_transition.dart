
import 'package:flutter/material.dart';
import 'package:flutter_application_1/wipe/animation/digital_wipe_panel.dart';

typedef TransitionBeforeBuilder = Widget Function(
  BuildContext context,
  VoidCallback onConfirm,
  bool isLoading,
);

typedef TransitionAfterBuilder = Widget Function(
  BuildContext context,
  Animation<double> entrance,
);

enum _TransitionPhase {
  idle,
  wipingIn,
  wipingOut,
  complete,
}

class WipeScreenTransition extends StatefulWidget {
  final TransitionBeforeBuilder beforeBuilder;
  final TransitionAfterBuilder afterBuilder;

  final Future<void> Function() onConfirm;

  final ValueChanged<Object>? onError;

  const WipeScreenTransition({
    super.key,
    required this.beforeBuilder,
    required this.afterBuilder,
    required this.onConfirm,
    this.onError,
  });

  @override
  State<WipeScreenTransition> createState() =>
      _WipeScreenTransitionState();
}

class _WipeScreenTransitionState
    extends State<WipeScreenTransition>
    with TickerProviderStateMixin {
  static const Color lightGreen = Color(0xFFE4F4DA);
  static const Color pdaxGreen = Color(0xFF39B402);

  static const Curve wipeCurve = Cubic(
    0.65,
    0.0,
    0.35,
    1.0,
  );

  static const Curve entranceCurve = Cubic(
    0.2,
    0.8,
    0.2,
    1.0,
  );

  static const Duration swapHoldDuration =
      Duration(milliseconds: 120);

  static const Duration successEntranceDuration =
      Duration(milliseconds: 760);

  static const Duration reducedMotionDuration =
      Duration(milliseconds: 200);

  late final AnimationController _wipeInController;
  late final AnimationController _wipeOutController;

  late final Animation<double> _lightGreenIn;
  late final Animation<double> _pdaxGreenIn;

  late final Animation<double> _pdaxGreenOut;
  late final Animation<double> _lightGreenOut;

  late final Animation<double> _successEntrance;

  _TransitionPhase _phase = _TransitionPhase.idle;

  bool _isLoading = false;
  bool _showAfter = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();

    _initializeWipeIn();
    _initializeWipeOut();
  }

  void _initializeWipeIn() {
    // Total duration:
    // 120ms stagger + 440ms panel animation = 560ms.

    _wipeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );

    // Light green starts immediately.
    _lightGreenIn = CurvedAnimation(
      parent: _wipeInController,
      curve: const Interval(
        0.0,
        440 / 560,
        curve: wipeCurve,
      ),
    );

    // PDAX green starts 120ms later.
    _pdaxGreenIn = CurvedAnimation(
      parent: _wipeInController,
      curve: const Interval(
        120 / 560,
        1.0,
        curve: wipeCurve,
      ),
    );
  }

  void _initializeWipeOut() {
    // PDAX green: 0ms - 520ms.
    // Light green: 120ms - 640ms.
    // Success entrance: 0ms - 760ms.

    _wipeOutController = AnimationController(
      vsync: this,
      duration: successEntranceDuration,
    );

    _pdaxGreenOut = CurvedAnimation(
      parent: _wipeOutController,
      curve: const Interval(
        0.0,
        520 / 760,
        curve: wipeCurve,
      ),
    );

    _lightGreenOut = CurvedAnimation(
      parent: _wipeOutController,
      curve: const Interval(
        120 / 760,
        640 / 760,
        curve: wipeCurve,
      ),
    );

    _successEntrance = CurvedAnimation(
      parent: _wipeOutController,
      curve: entranceCurve,
    );
  }

  Future<void> _handleConfirm() async {
    if (_isLoading || _showAfter) return;

    _reduceMotion = MediaQuery.of(context).disableAnimations;

    setState(() {
      _isLoading = true;
    });

    try {
      // Run the actual operation first.
      // Success is only displayed if the operation succeeds.
      await widget.onConfirm();

      if (!mounted) return;

      if (_reduceMotion) {
        // No wipe, slide, parallax, or stagger.
        // AnimatedSwitcher handles the 200ms crossfade.
        setState(() {
          _showAfter = true;
          _phase = _TransitionPhase.complete;
          _isLoading = false;
        });

        return;
      }

      // STEP 1: Wipe in.
      setState(() {
        _phase = _TransitionPhase.wipingIn;
      });

      await _wipeInController.forward(from: 0);

      if (!mounted) return;

      // STEP 2: Hold the fully covered screen.
      await Future.delayed(swapHoldDuration);

      if (!mounted) return;

      // STEP 3: Swap the underlying screen.
      setState(() {
        _showAfter = true;
        _phase = _TransitionPhase.wipingOut;
      });

      // STEP 4: Wipe out and reveal the success screen.
      await _wipeOutController.forward(from: 0);

      if (!mounted) return;

      setState(() {
        _phase = _TransitionPhase.complete;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _phase = _TransitionPhase.idle;
        _isLoading = false;
        _showAfter = false;
      });

      widget.onError?.call(error);
    }
  }

  Widget _buildCurrentScreen(BuildContext context) {
    final Animation<double> entrance = _reduceMotion
        ? const AlwaysStoppedAnimation<double>(1.0)
        : _successEntrance;

    final Widget screen = _showAfter
        ? widget.afterBuilder(context, entrance)
        : widget.beforeBuilder(
            context,
            _handleConfirm,
            _isLoading,
          );

    return AnimatedSwitcher(
      duration: _reduceMotion
          ? reducedMotionDuration
          : Duration.zero,
      switchInCurve: Curves.linear,
      switchOutCurve: Curves.linear,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey<bool>(_showAfter),
        child: screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _wipeInController,
        _wipeOutController,
      ]),
      builder: (context, child) {
        final isWipingIn =
            _phase == _TransitionPhase.wipingIn;

        final isWipingOut =
            _phase == _TransitionPhase.wipingOut;

        // Confirm screen parallax.
        final confirmProgress = isWipingIn
            ? _lightGreenIn.value
            : 0.0;

        // Success screen parallax.
        final successProgress = isWipingOut
            ? _successEntrance.value
            : 1.0;

        final double horizontalOffset = isWipingIn
            ? -24.0 * confirmProgress
            : isWipingOut
                ? 24.0 * (1.0 - successProgress)
                : 0.0;

        final double opacity = isWipingIn
            ? 1.0 - (0.4 * confirmProgress)
            : 1.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Underlying screen.
            Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(horizontalOffset, 0),
                child: _buildCurrentScreen(context),
              ),
            ),

            // WIPE IN.
            if (isWipingIn) ...[
              DiagonalWipePanel(
                color: lightGreen,
                progress: _lightGreenIn.value,
                direction: WipePanelDirection.enterFromRight,
              ),
              DiagonalWipePanel(
                color: pdaxGreen,
                progress: _pdaxGreenIn.value,
                direction: WipePanelDirection.enterFromRight,
              ),
            ],

            // WIPE OUT.
            if (isWipingOut) ...[
              // Light green is underneath PDAX green.
              DiagonalWipePanel(
                color: lightGreen,
                progress: _lightGreenOut.value,
                direction: WipePanelDirection.exitToLeft,
              ),

              // PDAX green leaves first.
              DiagonalWipePanel(
                color: pdaxGreen,
                progress: _pdaxGreenOut.value,
                direction: WipePanelDirection.exitToLeft,
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _wipeInController.dispose();
    _wipeOutController.dispose();

    super.dispose();
  }
}
