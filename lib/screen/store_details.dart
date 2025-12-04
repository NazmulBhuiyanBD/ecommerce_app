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
        backgroundColor: AppColors.primary,
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("shops").doc(shopId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final shop = snapshot.data!;
          final data = shop.data() as Map<String, dynamic>? ?? {};

          final String banner = data["bannerImage"] ??
              "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg";

          final String name = data["name"] ?? "No Name";
          final String status = data["status"] ?? "N/A";
          final String description = data["description"] ?? "No Description";
          final String ownerId = data["ownerId"] ?? "Unknown";

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= Banner =================
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

                      // ================= Name =================
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ================= Status Badge =================
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: status == "approved"
                              ? Colors.green.shade100
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Status: $status",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= Description =================
                      const Text(
                        "Description:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        description,
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Owner ID: $ownerId",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ================= Store Products =================
                      const Text(
                        "Store Products",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("products")
                            .where("shopId", isEqualTo: shopId)
                            .snapshots(),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final products = snap.data!.docs;

                          if (products.isEmpty) {
                            return const Text(
                              "No products available",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.65,
                            ),
                            itemBuilder: (_, index) {
                              final p = products[index].data()
                                  as Map<String, dynamic>? ?? {};

                              final img = p["image"] ??
                                  "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg";

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ItemDetailsScreen(product: p),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 6,
                                        color: Colors.black12,
                                      )
                                    ],
                                  ),
                                  child: Column(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p["name"] ?? "",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "৳ ${p["price"] ?? "0"}",
                                              style: const TextStyle(
                                                color: Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
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
