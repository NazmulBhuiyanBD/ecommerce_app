import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screen/all_products.dart';
import 'package:ecommerce_app/screen/categories_page.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'item_details_screen.dart';

String getProductImage(Map<String, dynamic> p) {
  if (p["images"] != null && p["images"] is List && p["images"].isNotEmpty) {
    return p["images"][0];
  }
  if (p["image"] != null && p["image"].toString().isNotEmpty) {
    return p["image"];
  }
  return "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/480px-No_image_available.svg.png";
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),
              const SizedBox(height: 16),
              _bannerSlider(),
              const SizedBox(height: 18),
              _quickMenu(),
              const SizedBox(height: 20),
              _featuredCategories(context),
              const SizedBox(height: 20),
              _featuredProducts(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.menu, size: 28, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 6,
                )
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Text("Search products...",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.notifications_none, size: 28, color: AppColors.primary),
      ],
    );
  }

  Widget _bannerSlider() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('banners')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()));
        }

        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const SizedBox(
              height: 160, child: Center(child: Text('No banners found')));
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              viewportFraction: 1,
            ),
            items: docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              final url = data["image"] ??
                  "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/480px-No_image_available.svg.png";

              return Image.network(url, width: double.infinity, fit: BoxFit.cover);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _quickMenu() {
    final items = [
      {'icon': Icons.category, 'label': 'Top Category'},
      {'icon': Icons.grade, 'label': 'Top'},
      {'icon': Icons.store_mall_directory, 'label': 'Shops'},
      {'icon': Icons.local_offer, 'label': 'Deals'},
      {'icon': Icons.bolt, 'label': 'Flash'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.map((it) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, const Color(0xFF7169E2)],
                ),
              ),
              child: Icon(it['icon'] as IconData,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 6),
            Text(it['label'] as String,
                style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }

  Widget _featuredCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Featured Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoriesPage()),
                  );
                },
                child: const Text("All Category"))
          ],
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 110,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              List docs = snap.data!.docs;
              docs.shuffle(Random());
              docs = docs.take(5).toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i].data() as Map<String, dynamic>;

                  final image = d["image"] ??
                      "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/480px-No_image_available.svg.png";

                  return Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                            child: Image.network(image, fit: BoxFit.contain)),
                        const SizedBox(height: 6),
                        Text(d['name'] ?? "",
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

Widget _featuredProducts(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Featured Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllProductsScreen()),
              );
            },
            child: const Text("See All Products"),
          ),
        ],
      ),
      const SizedBox(height: 12),

      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot> docs = snap.data!.docs;

          docs.shuffle(Random());
          docs = docs.take(5).toList();

          return GridView.builder(
            itemCount: docs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (_, i) {
              final doc = docs[i];
              final p = doc.data() as Map<String, dynamic>;
              final String productId = doc.id;    // ✅ FIXED PRODUCT ID

              final image = getProductImage(p);
              final price = p['price'] ?? 0;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemDetailsScreen(
                        product: p,
                        productId: productId,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        p['name'] ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "৳ $price",
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
    ],
  );
}
}
