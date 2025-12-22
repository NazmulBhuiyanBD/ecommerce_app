import 'package:ecommerce_app/screen/payment_Screen/bkash_payment.dart';
import 'package:ecommerce_app/screen/payment_Screen/nagad_payment.dart';
import 'package:ecommerce_app/screen/payment_Screen/ssl_payment.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

enum PaymentMethod { bkash, nagad, sslcommerz }

class PaymentSelectionPage extends StatefulWidget {
  final double payableAmount;
  final VoidCallback onSuccess;

  const PaymentSelectionPage({
    super.key,
    required this.payableAmount,
    required this.onSuccess,
  });

  @override
  State<PaymentSelectionPage> createState() => _PaymentSelectionPageState();
}

class _PaymentSelectionPageState extends State<PaymentSelectionPage> {
  PaymentMethod _selectedMethod = PaymentMethod.bkash;

  Future<void> _continuePayment() async {
    bool success = false;

    if (_selectedMethod == PaymentMethod.bkash) {
      success =
          await startBkashPayment(context, widget.payableAmount);
    } else if (_selectedMethod == PaymentMethod.nagad) {
      success = await startNagadPayment(
          context: context, amount: widget.payableAmount);
    } else {
      success = await startSSLCommerzPayment(
          context: context, amount: widget.payableAmount);
    }

    if (success) {
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text("Online Payment"),
        backgroundColor: AppColors.secondary,
        elevation: 0,
      ),
      body: Column(
        children: [
          _paymentTile("bKash", "assets/bkash.png", PaymentMethod.bkash),
          _paymentTile("Nagad", "assets/nagod.png", PaymentMethod.nagad),
          _paymentTile(
              "SSLCommerz", "assets/sslcommerz.png", PaymentMethod.sslcommerz),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Payable"),
                    Text(
                      "৳ ${widget.payableAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: _continuePayment,
                    child: const Text("Continue to payment"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _paymentTile(String title, String asset, PaymentMethod value) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: RadioListTile<PaymentMethod>(
        value: value,
        groupValue: _selectedMethod,
        onChanged: (v) => setState(() => _selectedMethod = v!),
        title: Row(
          children: [
            Image.asset(asset, height: 30,),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
      ),
    );
  }
}
