import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'item_details_screen.dart';

// safe image getter (handles `images` list, `image` string, or missing)
String getProductImage(Map<String, dynamic> p) {
  try {
    if (p.containsKey('images') && p['images'] is List && (p['images'] as List).isNotEmpty) {
      final first = (p['images'] as List).first;
      if (first != null && first.toString().isNotEmpty) return first.toString();
    }
    if (p.containsKey('image') && p['image'] != null && p['image'].toString().isNotEmpty) {
      return p['image'].toString();
    }
  } catch (_) {}
  return 'https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg';
}

class ItemListByCategory extends StatelessWidget {
  final String category;

  const ItemListByCategory({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: Text(category),
        backgroundColor: AppColors.secondary,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("products")
            .where("category", isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No products found in this category",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.63,
            ),
            itemBuilder: (_, index) {
              final raw = products[index].data();
              // normalize to Map<String,dynamic> safely
              final Map<String, dynamic> product =
                  (raw is Map<String, dynamic>) ? raw : Map<String, dynamic>.from({});

              final imageUrl = getProductImage(product);
              final name = (product['name'] ?? 'Unnamed Product').toString();
              final priceVal = product['price'];
              final priceStr = priceVal != null ? priceVal.toString() : '0';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemDetailsScreen(product: product),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "৳ $priceStr",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
