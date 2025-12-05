import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screen/item_details_screen.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

class StoreDetailsScreen extends StatelessWidget {
  final String shopId;

  const StoreDetailsScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text("Store Details"),
        backgroundColor: AppColors.secondary,
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("shops").doc(shopId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final String banner = data["bannerImage"] ??
              "https://upload.wikimedia.org/wikipedia/commons/ac/No_image_available.svg";

          final String name = data["name"] ?? "No Name";
          final String description = data["description"] ?? "No Description";

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // STORE BANNER
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: Image.network(
                    banner,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Description:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        description,
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Store Products",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 12),

                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("products")
                            .where("shopId", isEqualTo: shopId)
                            .snapshots(),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final items = snap.data!.docs;
                          if (items.isEmpty) {
                            return const Text(
                              "No products available",
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.63,
                            ),

                            itemBuilder: (_, index) {
                              final productId = items[index].id;
                              final p = items[index].data() as Map<String, dynamic>;

                              final List images = p["images"] ?? [];
                              final String img = images.isNotEmpty
                                  ? images[0]
                                  : "https://upload.wikimedia.org/wikipedia/commons/ac/No_image_available.svg";

                              final double price = (p["price"] ?? 0).toDouble();
                              final double discount = (p["discount"] ?? 0).toDouble();
                              final double finalPrice = price - discount;

                              final int stock = p["stock"] ?? 0;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ItemDetailsScreen(
                                        productId: productId,
                                        product: p,
                                      ),
                                    ),
                                  );
                                },

                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 5,
                                        color: Colors.black12,
                                      ),
                                    ],
                                  ),

                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          img,
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Text(
                                              p["name"] ?? "",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            // PRICE
                                            discount > 0
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "৳ ${finalPrice.toStringAsFixed(2)}",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.red,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        "৳ ${price.toStringAsFixed(2)}",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                          decoration:
                                                              TextDecoration.lineThrough,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    "৳ ${price.toStringAsFixed(2)}",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.orange,
                                                    ),
                                                  ),

                                            const SizedBox(height: 6),

                                            Text(
                                              "Stock: $stock",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: stock > 0
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
