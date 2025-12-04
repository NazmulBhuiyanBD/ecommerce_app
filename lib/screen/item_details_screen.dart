import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/provider/cart_provider.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ItemDetailsScreen({super.key, required this.product});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int selectedImage = 0;
  int quantity = 1;

  String shopName = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchShopName();
  }

Future<void> fetchShopName() async {
  try {
    DocumentSnapshot shop = await FirebaseFirestore.instance
        .collection("shops")
        .doc(widget.product["shopId"])
        .get();

    setState(() {
      shopName = shop["name"] ?? "Unknown Seller";  // FIXED HERE
    });
  } catch (e) {
    setState(() {
      shopName = "Unknown Seller";
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final product = widget.product;

    final String name = product["name"] ?? "No Name";
    final double price = (product["price"] ?? 0).toDouble();
    final String description =
        product["description"] ?? "No description available.";

    final List images = product["images"] ?? [];
    final double totalPrice = price * quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: AppColors.primary,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= IMAGE GALLERY =====================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small Images Left
                Column(
                  children: List.generate(images.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedImage = index);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedImage == index
                                ? Colors.orange
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

                // Main Image
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      images.isNotEmpty ? images[selectedImage] : "",
                      height: 260,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ================= PRODUCT NAME =====================
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // ================= PRICE =====================
            Text(
              "৳ $price",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ================= QUANTITY SELECTOR =====================
            Row(
              children: [
                const Text(
                  "Quantity:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
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
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => quantity++);
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 10),

            // ================= TOTAL PRICE =====================
            Text(
              "Total Price: ৳ ${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 25),

            // ================= SELLER SECTION =====================
            Row(
              children: [
                const Icon(Icons.store, size: 28),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Seller:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      shopName,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ================= DESCRIPTION =====================
            const Text(
              "Description:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      // ================= BOTTOM BUTTONS =====================
      bottomNavigationBar: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {
                  for (int i = 0; i < quantity; i++) {
                    cart.addToCart(product);
                  }
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
                onPressed: () {},
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
