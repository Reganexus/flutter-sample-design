
import 'package:flutter/material.dart';

import 'confirm_order_button.dart';

class ConfirmOrderScreen extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool isLoading;

  const ConfirmOrderScreen({
    super.key,
    required this.onConfirm,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Confirm Order',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const Text(
                'Almost there!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Review your order before confirming.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 32),

              _buildOrderSummary(),

              const Spacer(),

              ConfirmOrderButton(
                onPressed: onConfirm,
                isLoading: isLoading,
                disableAnimations: disableAnimations,
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Please review your order carefully.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 20),

          _OrderSummaryRow(
            label: 'Product',
            value: 'Sample Product',
          ),

          SizedBox(height: 14),

          _OrderSummaryRow(
            label: 'Quantity',
            value: '2',
          ),

          SizedBox(height: 14),

          Divider(),

          SizedBox(height: 14),

          _OrderSummaryRow(
            label: 'Total',
            value: '₱1,500.00',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _OrderSummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: Colors.black87,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(value, style: textStyle),
      ],
    );
  }
}
