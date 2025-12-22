import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/auth/login_page.dart';
import 'package:ecommerce_app/service/auth_service.dart';
import 'package:ecommerce_app/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_product_page.dart';
import 'shop_orders_page.dart';
import 'shop_owner_products_page.dart';
import 'shop_settings_page.dart';

class ShopOwnerDashboard extends StatefulWidget {
  const ShopOwnerDashboard({super.key});

  @override
  State<ShopOwnerDashboard> createState() => _ShopOwnerDashboardState();
}

class _ShopOwnerDashboardState extends State<ShopOwnerDashboard> {
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

    shopId = userDoc.data()?["shopId"] ?? "";
    setState(() => loading = false);
  }

  Stream<int> productCountStream() {
    return FirebaseFirestore.instance
        .collection("products")
        .where("shopId", isEqualTo: shopId)
        .snapshots()
        .map((snap) => snap.size);
  }

  Stream<int> orderCountStream() {
    return FirebaseFirestore.instance.collection("orders").snapshots().map(
      (snap) {
        int count = 0;
        for (var doc in snap.docs) {
          final products = doc["products"] as List<dynamic>;
          if (products.any((p) => p["shopId"] == shopId)) {
            count++;
          }
        }
        return count;
      },
    );
  }

  void logout(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
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
        title: const Text(
          "Shop Owner Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => logout(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: 0.9,
          children: [
            modernTile(
              title: "Shop Settings",
              icon: Icons.settings,
              gradient: const [Color(0xff6a11cb), Color(0xff2575fc)],
              showCount: false,
              stream: Stream.value(0),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopSettingsPage()),
              ),
            ),

            modernTile(
              title: "Add Product",
              icon: Icons.add_box_rounded,
              gradient: const [Color(0xff11998e), Color(0xff38ef7d)],
              showCount: false,
              stream: Stream.value(0),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductPage()),
              ),
            ),

            /// ONLY SHOW IF SHOP EXISTS
            if (shopId.isNotEmpty)
              modernTile(
                title: "My Products",
                icon: Icons.inventory,
                gradient: const [Color(0xffff512f), Color(0xffdd2476)],
                showCount: true,
                stream: productCountStream(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ShopOwnerProductsPage()),
                ),
              ),

            if (shopId.isNotEmpty)
              modernTile(
                title: "Orders",
                icon: Icons.receipt_long,
                gradient: const [Color(0xffee0979), Color(0xffff6a00)],
                showCount: true,
                stream: orderCountStream(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShopOrdersPage()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget modernTile({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required Stream<int> stream,
    required VoidCallback onTap,
    bool showCount = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: gradient.first,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 14),
            if (showCount)
              StreamBuilder<int>(
                stream: stream,
                builder: (_, snap) {
                  return Text(
                    "${snap.data ?? 0}",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: gradient.first,
                    ),
                  );
                },
              ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
