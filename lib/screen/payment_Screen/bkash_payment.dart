import 'package:flutter/material.dart';
import 'package:flutter_bkash/flutter_bkash.dart';

Future<bool> startBkashPayment(
  BuildContext context,
  double amount,
) async {
  final flutterBkash = FlutterBkash(logResponse: true);

  try {
    final result = await flutterBkash.pay(
      context: context,
      amount: amount, 
      merchantInvoiceNumber:
          "INV_${DateTime.now().millisecondsSinceEpoch}",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("bKash Success: ${result.trxId}")),
    );

    return true; 
  } on BkashFailure catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );

    return false; 
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment cancelled")),
    );

    return false; 
  }
}
