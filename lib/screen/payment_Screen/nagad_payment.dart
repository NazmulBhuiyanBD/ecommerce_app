import 'package:flutter/material.dart';
import 'package:nagad_payment_gateway/nagad_payment_gateway.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> startNagadPayment({
  required BuildContext context,
  required double amount,
}) async {
  try {
    final nagad = Nagad(
      credentials: const NagadCredentials(
        merchantID: "YOUR_MERCHANT_ID",
        merchantPrivateKey: "YOUR_MERCHANT_PRIVATE_KEY",
        pgPublicKey: "NAGAD_PAYMENT_GATEWAY_PUBLIC_KEY",
        isSandbox: true,
      ),
    );

    nagad.setAdditionalMerchantInfo({
      "serviceName": "Ecommerce Shop",
      "serviceLogoURL": "https://yourdomain.com/logo.png",
      "additionalFieldNameEN": "Order",
      "additionalFieldNameBN": "অর্ডার",
      "additionalFieldValue": "Online Purchase",
    });

    final String orderId =
        "order_${DateTime.now().millisecondsSinceEpoch}";

    final NagadResponse response = await nagad.regularPayment(
      context,
      amount: amount,
      orderId: orderId,
    );

    return _handleNagadResponse(response);
  } catch (e) {
    Fluttertoast.showToast(
      msg: "Nagad payment cancelled",
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    return false;
  }
}

bool _handleNagadResponse(NagadResponse response) {
  final status = response.status?.toLowerCase();

  if (status == "success") {
    Fluttertoast.showToast(
      msg: "Nagad Payment Successful\nRef: ${response.paymentRefId}",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    return true;
  }

  Fluttertoast.showToast(
    msg: "Payment ${response.status ?? 'failed'}",
    backgroundColor: Colors.orange,
    textColor: Colors.white,
  );
  return false;
}
