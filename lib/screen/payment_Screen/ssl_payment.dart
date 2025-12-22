import 'package:ecommerce_app/utils/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> startSSLCommerzPayment({
  required BuildContext context,
  required double amount,
}) async {
  try {
    final sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        store_id: Env.sslstore_id,
        store_passwd: Env.sslstore_passwd,
        currency: SSLCurrencyType.BDT,
        total_amount: amount,
        tran_id: "TXN_${DateTime.now().millisecondsSinceEpoch}",
        product_category: "Ecommerce",
        sdkType: SSLCSdkType.TESTBOX, 
        // ipn_url: "https://example.com/ipn", 
      ),
    );

    final SSLCTransactionInfoModel result =
        await sslcommerz.payNow();

    return _handleResult(result);
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Payment cancelled",
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    return false;
  }
}

bool _handleResult(SSLCTransactionInfoModel result) {
  switch (result.status?.toLowerCase()) {
    case "valid":
    case "success":
      Fluttertoast.showToast(
        msg: "Payment Successful: ৳${result.amount}",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      return true;

    case "failed":
      Fluttertoast.showToast(
        msg: "Payment Failed",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;

    case "closed":
      Fluttertoast.showToast(
        msg: "Payment Cancelled",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return false;

    default:
      Fluttertoast.showToast(
        msg: "Unknown status: ${result.status}",
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
      return false;
  }
}
