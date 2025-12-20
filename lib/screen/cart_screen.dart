import 'package:ecommerce_app/auth/login_page.dart';
import 'package:ecommerce_app/provider/cart_provider.dart';
import 'package:ecommerce_app/screen/checkout_page.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.secondary,

      appBar: AppBar(
        title: const Text("My Cart"),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
      ),

      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              itemBuilder: (_, index) {
                final item = cart.items[index];
                final productId = item.productId;
                final p = item.product;

                final double price = (p["price"] ?? 0).toDouble();
                final double discount = (p["discount"] ?? 0).toDouble();
                final double finalPrice = price - discount;

                final List images = p["images"] ?? [];
                final String img = images.isNotEmpty
                    ? images[0]
                    : p["image"] ??
                        "https://drive.google.com/file/d/1e6cz8vgwIcljKau_pnd3f3-PmTyMXIn2/view?usp=sharing";

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        img,
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                      ),
                    ),

                    title: Text(p["name"] ?? "Unknown Product"),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (discount > 0) ...[
                          Text(
                            "৳ ${finalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "৳ ${price.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough),
                          ),
                        ] else
                          Text(
                            "৳ ${price.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
                          ),
                      ],
                    ),

                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => cart.decrease(productId),
                          ),

                          Text(
                            "${item.quantity}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),

                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => cart.increase(productId),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

bottomNavigationBar: cart.items.isEmpty
    ? const SizedBox()
    : Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ----------------- TOTAL DISCOUNT -----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Discount:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                Text(
                  "- ৳ ${cart.totalDiscount().toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ----------------- PAYABLE AFTER DISCOUNT -----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Discount Applied:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "- ৳ ${cart.totalDiscount().toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ----------------- FINAL TOTAL -----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "৳ ${cart.totalPrice().toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

// ----------------- CHECKOUT BUTTON -----------------
SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    onPressed: () {
      final user = FirebaseAuth.instance.currentUser;

      // if user is not logged in → go to login page
      if (user == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return;
      }

      // go to checkout page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CheckoutPage()),
      );
    },
    child: const Text(
      "Checkout",
      style: TextStyle(fontSize: 18),
    ),
  ),
),

          ],
        ),
      ),

    );
  }
}
