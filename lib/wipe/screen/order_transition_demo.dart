
import 'package:flutter/material.dart';
import 'package:flutter_application_1/wipe/animation/wipe_screen_transition.dart';

import '../widgets/confirm_order_screen.dart';
import '../widgets/order_success_screen.dart';

class OrderTransitionDemo extends StatelessWidget {
  const OrderTransitionDemo({super.key});

  Future<void> _placeOrder() async {
    // Simulate a network request.
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    // In your actual application, invoke your use case here.
    //
    // await placeOrderUseCase.call(order);
  }

  @override
  Widget build(BuildContext context) {
    return WipeScreenTransition(
      onConfirm: _placeOrder,

      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to place order: $error'),
          ),
        );
      },

      beforeBuilder: (
        context,
        onConfirm,
        isLoading,
      ) {
        return ConfirmOrderScreen(
          onConfirm: onConfirm,
          isLoading: isLoading,
        );
      },

      afterBuilder: (
        context,
        entrance,
      ) {
        return OrderSuccessScreen(
          entrance: entrance,
        );
      },
    );
  }
}
