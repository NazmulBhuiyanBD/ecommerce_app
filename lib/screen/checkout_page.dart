import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/provider/cart_provider.dart';
import 'package:ecommerce_app/screen/payment_Screen/payment_selection_page.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  final bool isBuyNow;
  final List<Map<String, dynamic>>? buyNowItems;

  const CheckoutPage({
    super.key,
    this.isBuyNow = false,
    this.buyNowItems,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String paymentMethod = "Cash on Delivery";
  static const double deliveryCharge = 2.0;
  bool loading = false;

  Future<void> placeOrder({required String method}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_nameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => loading = true);

    final cart = context.read<CartProvider>();

    final List<Map<String, dynamic>> products =
        widget.isBuyNow ? widget.buyNowItems! : cart.items.map((item) {
          final p = item.product;
          final price = (p["price"] ?? 0).toDouble();
          final discount = (p["discount"] ?? 0).toDouble();

          return {
            "productId": item.productId,
            "name": p["name"],
            "price": price,
            "discount": discount,
            "finalPrice": price - discount,
            "image": (p["images"] != null && p["images"].isNotEmpty)
                ? p["images"][0]
                : p["image"],
            "quantity": item.quantity,
            "shopId": p["shopId"],
          };
        }).toList();

    double subtotal = 0;
    double totalDiscount = 0;

    for (var p in products) {
      subtotal += p["price"] * p["quantity"];
      totalDiscount += p["discount"] * p["quantity"];
    }

    final orderData = {
      "userId": user.uid,
      "name": _nameCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
      "address": _addressCtrl.text.trim(),
      "paymentMethod": method,
      "products": products,
      "deliveryCharge": deliveryCharge,
      "totalDiscount": totalDiscount,
      "totalPrice": subtotal + deliveryCharge - totalDiscount,
      "status": "Pending",
      "timestamp": FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection("orders").add(orderData);

    if (!widget.isBuyNow) {
      cart.clear();
    }

    if (!mounted) return;
    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order placed successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    final items = widget.isBuyNow
        ? widget.buyNowItems!
        : cart.items.map((e) {
            final p = e.product;
            return {
              "price": p["price"],
              "discount": p["discount"] ?? 0,
              "quantity": e.quantity,
            };
          }).toList();

    double subtotal = 0;
    double discount = 0;

    for (var i in items) {
      subtotal += i["price"] * i["quantity"];
      discount += i["discount"] * i["quantity"];
    }

    final totalPayable = subtotal + deliveryCharge - discount;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _iconInput(Icons.person, "Full Name", _nameCtrl),
            _iconInput(Icons.phone, "Phone Number", _phoneCtrl,
                keyboard: TextInputType.phone),
            _iconInput(Icons.location_on, "Delivery Address", _addressCtrl,
                maxLines: 2),

            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: paymentMethod,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Payment Method",
              ),
              items: const [
                DropdownMenuItem(
                    value: "Cash on Delivery",
                    child: Text("Cash on Delivery")),
                DropdownMenuItem(
                    value: "Online Pay", child: Text("Online Pay")),
              ],
              onChanged: (v) => setState(() => paymentMethod = v.toString()),
            ),

            const SizedBox(height: 20),

            _summaryRow("Delivery Charge", deliveryCharge),
            _summaryRow("Total Discount", -discount),
            const Divider(),
            _summaryRow("Total Payable", totalPayable, bold: true),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: loading
                    ? null
                    : () {
                        if (paymentMethod == "Online Pay") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentSelectionPage(
                                payableAmount: totalPayable,
                                onSuccess: () =>
                                    placeOrder(method: "Online Pay"),
                              ),
                            ),
                          );
                        } else {
                          placeOrder(method: "Cash on Delivery");
                        }
                      },
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Pay ৳ ${totalPayable.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconInput(IconData icon, String hint, TextEditingController ctrl,
      {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String title, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
          Text(
            "৳ ${value.toStringAsFixed(2)}",
            style: TextStyle(
              color:Colors.white,
                fontSize: 16,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
