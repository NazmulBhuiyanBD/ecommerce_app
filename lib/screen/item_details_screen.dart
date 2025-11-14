import 'package:ecommerce_app/provider/cart_provider.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ItemDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ItemDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(product["name"] ?? "Product Details"),
        backgroundColor: AppColors.primary,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------------- IMAGE ----------------
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product["image"],
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- NAME ----------------
            Text(
              product["name"] ?? "",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // ---------------- PRICE ----------------
            Text(
              "৳ ${product["price"]}",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- DESCRIPTION ----------------
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              product["description"] ?? "No description available.",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // ---------------- ADD TO CART BUTTON ----------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        height: 70,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            cart.addToCart(product);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Added to cart"),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text(
            "Add to Cart",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
