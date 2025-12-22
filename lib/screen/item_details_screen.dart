import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/provider/cart_provider.dart';
import 'package:ecommerce_app/screen/checkout_page.dart';
import 'package:ecommerce_app/screen/store_details.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final String productId;

  const ItemDetailsScreen({
    super.key,
    required this.product,
    required this.productId,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int selectedImage = 0;
  int quantity = 1;

  String shopName = "Loading...";
  String? shopId;

  @override
  void initState() {
    super.initState();
    fetchShopName();
  }

  Future<void> fetchShopName() async {
    try {
      final shop = await FirebaseFirestore.instance
          .collection("shops")
          .doc(widget.product["shopId"])
          .get();

      if (shop.exists) {
        setState(() {
          shopName = shop.data()?["name"] ?? "Unknown Seller";
          shopId = shop.id;
        });
      }
    } catch (_) {
      setState(() => shopName = "Unknown Seller");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final p = widget.product;

    final String name = p["name"] ?? "No Name";
    final double price = (p["price"] ?? 0).toDouble();
    final double discount = (p["discount"] ?? 0).toDouble();
    final double finalPrice = price - discount;
    final int stock = p["stock"] ?? 0;
    final List images = p["images"] ?? [];

    final double totalPrice = finalPrice * quantity;

    return Scaffold(
      backgroundColor: AppColors.secondary, 
      appBar: AppBar(
        title: Text(name),
        backgroundColor: AppColors.secondary,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: List.generate(images.length, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedImage = index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedImage == index
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          images[index],
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      images.isNotEmpty
                          ? images[selectedImage]
                          : "https://drive.google.com/file/d/1e6cz8vgwIcljKau_pnd3f3-PmTyMXIn2/view?usp=drive_link",
                      height: 260,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // ---------------- PRICE ----------------
            discount > 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "৳ ${finalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "৳ ${price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  )
                : Text(
                    "৳ ${price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

            const SizedBox(height: 10),
            Text(
              stock > 0 ? "In Stock: $stock" : "Out of Stock",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: stock > 0 ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Text(
                  "Quantity:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 15),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: quantity < stock
                            ? () => setState(() => quantity++)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              "Total Price: ৳ ${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            GestureDetector(
              onTap: shopId == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoreDetailsScreen(shopId: shopId!),
                        ),
                      );
                    },
              child: Row(
                children: [
                  const Icon(Icons.store, size: 28),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Seller:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        shopName,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Description:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              p["description"] ?? "No description available",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: AppColors.secondary,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: stock == 0
                    ? null
                    : () {
                        cart.addToCart(
                          widget.productId,
                          {...p, "quantity": quantity},
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Added to cart")),
                        );
                      },
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(width: 12),

Expanded(
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
    ),
    onPressed: stock == 0
        ? null
        : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CheckoutPage(
                  isBuyNow: true,
                  buyNowItems: [
                    {
                      "productId": widget.productId,
                      "name": p["name"],
                      "price": price,
                      "discount": discount,
                      "finalPrice": finalPrice,
                      "image": (p["images"] != null && p["images"].isNotEmpty)
                          ? p["images"][0]
                          : p["image"],
                      "quantity": quantity,
                      "shopId": p["shopId"],
                    }
                  ],
                ),
              ),
            );
          },
    child: const Text(
      "Buy Now",
      style: TextStyle(fontSize: 18, color: Colors.white),
    ),
  ),
),


          ],
        ),
      ),
    );
  }
}
