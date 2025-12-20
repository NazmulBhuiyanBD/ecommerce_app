import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/provider/cart_provider.dart';
import 'package:ecommerce_app/screen/main_page.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  String _paymentMethod = "Cash on Delivery";
  bool loading = false;

  Future<void> placeOrder() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (_name.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // Prepare product list properly
      final List<Map<String, dynamic>> productList = cart.items.map((item) {
        final p = item.product;
        final price = (p["price"] ?? 0).toDouble();
        final discount = (p["discount"] ?? 0).toDouble();
        final finalPrice = price - discount;

        // safe image
        final List imgs = p["images"] ?? [];
        final img = imgs.isNotEmpty ? imgs[0] : p["image"];

        return {
          "productId": item.productId,
          "name": p["name"],
          "price": price,
          "discount": discount,
          "finalPrice": finalPrice,
          "image": img,
          "quantity": item.quantity,
           "shopId": p["shopId"],
        };
      }).toList();

      final orderData = {
        "userId": user.uid,
        "name": _name.text.trim(),
        "phone": _phone.text.trim(),
        "address": _address.text.trim(),
        "paymentMethod": _paymentMethod,
        "products": productList,
        "totalDiscount": cart.totalDiscount(),
        "totalPrice": cart.totalPrice(),
        "status": "Pending",
        "timestamp": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection("orders").add(orderData);

      cart.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- SHIPPING FORM ----------------
            const Text("Shipping Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _address,
              decoration: const InputDecoration(
                labelText: "Full Address",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 25),

            // ---------------- PAYMENT METHOD ----------------
            const Text("Payment Method",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            DropdownButtonFormField(
              value: _paymentMethod,
              items: const [
                DropdownMenuItem(
                    value: "Cash on Delivery",
                    child: Text("Cash on Delivery")),
                DropdownMenuItem(value: "Bkash", child: Text("Bkash Payment")),
                DropdownMenuItem(value: "Nagad", child: Text("Nagad Payment")),
              ],
              onChanged: (value) {
                setState(() => _paymentMethod = value.toString());
              },
            ),

            const SizedBox(height: 25),

            // ---------------- ORDER SUMMARY ----------------
            const Text("Order Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ...cart.items.map((item) {
              final p = item.product;
              final List imgs = p["images"] ?? [];
              final img = imgs.isNotEmpty ? imgs[0] : p["image"];

              final price = (p["price"] ?? 0).toDouble();
              final discount = (p["discount"] ?? 0).toDouble();
              final finalPrice = price - discount;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.network(img, width: 50, height: 50),
                title: Text(p["name"]),
                subtitle: Text(
                    "৳${finalPrice.toStringAsFixed(2)}   |   Qty: ${item.quantity}"),
              );
            }).toList(),

            const Divider(),

            // ---------------- DISCOUNT ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Discount:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  "- ৳ ${cart.totalDiscount().toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),

  
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Payable:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  "৳ ${cart.totalPrice().toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),


            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Place Order",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
