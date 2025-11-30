import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'edit_product_page.dart';

class ShopOwnerProductsPage extends StatefulWidget {
  const ShopOwnerProductsPage({super.key});

  @override
  State<ShopOwnerProductsPage> createState() => _ShopOwnerProductsPageState();
}

class _ShopOwnerProductsPageState extends State<ShopOwnerProductsPage> {
  String searchQuery = "";
  int page = 0;
  final int limit = 10;

  String shopId = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadShopId();
  }

  Future<void> loadShopId() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    shopId = userDoc["shopId"];

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text("My Products"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search product by name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value.trim());
              },
            ),

            const SizedBox(height: 15),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("products")
                    .where("shopId", isEqualTo: shopId)
                    .snapshots(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final all = snapshot.data!.docs;

                  final filtered = all.where((p) {
                    final name = (p["name"] ?? "").toString().toLowerCase();
                    return name.contains(searchQuery.toLowerCase());
                  }).toList();

                  final total = filtered.length;
                  final start = page * limit;
                  final end = (start + limit > total) ? total : start + limit;

                  final products = filtered.sublist(start, end);

                  if (products.isEmpty) {
                    return const Center(child: Text("No products found"));
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (_, index) {
                            final p = products[index];
                            final img = (p["images"] != null &&
                                    p["images"].isNotEmpty)
                                ? p["images"][0]
                                : null;

                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: img != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          img,
                                          width: 55,
                                          height: 55,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.image, size: 45),

                                title: Text(
                                  p["name"] ?? "Unnamed Product",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),

                                subtitle: Text("৳ ${p["price"]}"),

                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditProductPage(productId: p.id),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      if (total > limit)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed:
                                  page > 0 ? () => setState(() => page--) : null,
                              child: const Text("Previous"),
                            ),
                            const SizedBox(width: 15),
                            ElevatedButton(
                              onPressed: end < total
                                  ? () => setState(() => page++)
                                  : null,
                              child: const Text("Next"),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
